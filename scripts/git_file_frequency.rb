#!/usr/bin/env ruby
# frozen_string_literal: true

require 'date'
require 'time'

# Git File Frequency Analyzer
#
# Analyzes git commit history to identify frequently changed files
# Provides both absolute frequency and recency-weighted rankings
#
# Usage: ruby git_file_frequency.rb [options]
#   --limit N        Show top N files (default: 20)
#   --decay-rate R   Set decay rate for recency weighting (default: 0.5)
#   --target-dir DIR Analyze git repository at DIR (default: current directory)
#   --help           Show this help message

class GitFileFrequencyAnalyzer
  SECONDS_PER_YEAR = 365.25 * 24 * 60 * 60

  # Files to exclude from analysis (infrastructure/config files)
  EXCLUDED_FILES = [
    'Gemfile',
    'Gemfile.lock',
    'yarn.lock',
    'package.json',
    'schema.rb',
    'structure.sql',
    'routes.rb',
    'schema.graphql',
    '.rubocop.yml',
    'semaphore.yml'
  ].freeze

  EXCLUDED_PATTERNS = [
    %r{lib/tasks/one_off\.rake$},
    %r{db/schema\.rb$},
    %r{db/structure\.sql$},
    %r{config/routes\.rb$},
    %r{\.semaphore/semaphore\.yml$}
  ].freeze

  def initialize(limit: 20, decay_rate: 0.5, target_dir: nil)
    @limit = limit
    @decay_rate = decay_rate # Higher = faster decay of old commits
    @target_dir = target_dir
    @absolute_frequencies = Hash.new(0)
    @weighted_frequencies = Hash.new(0.0)
    @file_last_changed = {}
    @excluded_count = 0
  end

  def analyze
    puts "🔍 Analyzing git commit history...\n"
    puts "   📁 Repository: #{@target_dir || '.'}\n\n" if @target_dir

    parse_git_log
    display_results
  end

  private

  def parse_git_log
    # Get all commits with file change stats and dates
    # Format: commit_hash | author_date | filename | additions | deletions
    git_log = git_command("log --all --numstat --date=iso --pretty=format:'COMMIT|%ad'")

    current_date = nil
    now = Time.now

    git_log.each_line do |line|
      line = line.strip
      next if line.empty?

      if line.start_with?('COMMIT|')
        # Parse commit date
        date_str = line.split('|', 2).last
        current_date = Time.parse(date_str)
      elsif current_date && line =~ /^(\d+|-)\s+(\d+|-)\s+(.+)$/
        # Parse file change: additions deletions filename
        filename = ::Regexp.last_match(3)

        # Skip binary files and deletions
        next if ::Regexp.last_match(1) == '-' || filename.include?('=>')

        # Skip excluded files
        if should_exclude_file?(filename)
          @excluded_count += 1
          next
        end

        # Track absolute frequency
        @absolute_frequencies[filename] += 1

        # Calculate recency weight using exponential decay
        # weight = e^(-decay_rate * years_ago)
        years_ago = (now - current_date) / SECONDS_PER_YEAR
        weight = Math.exp(-@decay_rate * years_ago)

        @weighted_frequencies[filename] += weight

        # Track most recent change
        @file_last_changed[filename] = current_date if @file_last_changed[filename].nil? || current_date > @file_last_changed[filename]
      end
    end
  end

  def display_results
    # Sort by frequency
    absolute_sorted = @absolute_frequencies.sort_by { |_file, count| -count }.first(@limit)
    weighted_sorted = @weighted_frequencies.sort_by { |_file, score| -score }.first(@limit)

    display_absolute_frequency(absolute_sorted)
    puts "\n#{'-' * 80}\n\n"
    display_weighted_frequency(weighted_sorted)
    display_summary
  end

  def display_absolute_frequency(sorted_files)
    puts "📊 TOP #{@limit} FILES BY ABSOLUTE CHANGE FREQUENCY"
    puts "=" * 80
    puts format("%-4s %-8s %-15s %s", "Rank", "Changes", "Last Changed", "File")
    puts "-" * 80

    sorted_files.each_with_index do |(filename, count), index|
      last_changed = format_date(@file_last_changed[filename])
      puts format("%-4d %-8d %-15s %s", index + 1, count, last_changed, filename)
    end
  end

  def display_weighted_frequency(sorted_files)
    puts "⏰ TOP #{@limit} FILES BY RECENCY-WEIGHTED FREQUENCY"
    puts "=" * 80
    puts "(Recent changes weighted higher, decay rate: #{@decay_rate})"
    puts "-" * 80
    puts format("%-4s %-10s %-8s %-15s %s", "Rank", "Weight", "Changes", "Last Changed", "File")
    puts "-" * 80

    sorted_files.each_with_index do |(filename, score), index|
      absolute_count = @absolute_frequencies[filename]
      last_changed = format_date(@file_last_changed[filename])
      puts format("%-4d %-10.2f %-8d %-15s %s", index + 1, score, absolute_count, last_changed, filename)
    end
  end

  def should_exclude_file?(filename)
    # Check exact filename matches
    basename = File.basename(filename)
    return true if EXCLUDED_FILES.include?(basename)

    # Check pattern matches
    EXCLUDED_PATTERNS.any? { |pattern| filename.match?(pattern) }
  end

  def display_summary
    puts "\n" + "=" * 80
    puts "📈 SUMMARY"
    puts "-" * 80
    puts "Total unique files analyzed: #{@absolute_frequencies.size}"
    puts "Total file changes excluded: #{@excluded_count}"
    puts "Total commits processed: #{count_total_commits}"
    puts "Decay rate (higher = more recent bias): #{@decay_rate}"
    puts "\n🚫 Excluded files: #{EXCLUDED_FILES.join(', ')}"
    puts "\n💡 Interpretation:"
    puts "   • Absolute ranking shows all-time most frequently changed files"
    puts "   • Weighted ranking emphasizes recent activity over historical changes"
    puts "   • Files with high absolute but low weighted rank are 'legacy hotspots'"
  end

  def count_total_commits
    git_command('rev-list --all --count').strip.to_i
  end

  def git_command(cmd)
    if @target_dir
      `git -C "#{@target_dir}" #{cmd}`
    else
      `git #{cmd}`
    end
  end

  def format_date(time)
    return 'Unknown' if time.nil?

    days_ago = ((Time.now - time) / (24 * 60 * 60)).to_i

    case days_ago
    when 0 then 'Today'
    when 1 then 'Yesterday'
    when 2..7 then "#{days_ago}d ago"
    when 8..30 then "#{days_ago / 7}w ago"
    when 31..365 then "#{days_ago / 30}mo ago"
    else "#{days_ago / 365}y ago"
    end
  end
end

# Parse command line arguments
options = {
  limit: 20,
  decay_rate: 0.5,
  target_dir: nil
}

args = ARGV.dup
while (arg = args.shift)
  case arg
  when '--limit'
    options[:limit] = args.shift.to_i
  when '--decay-rate'
    options[:decay_rate] = args.shift.to_f
  when '--target-dir'
    options[:target_dir] = args.shift
  when '--help', '-h'
    puts File.read(__FILE__).split("\n")[2..10].map { |l| l.sub(/^# ?/, '') }.join("\n")
    exit 0
  else
    puts "Unknown option: #{arg}"
    puts "Use --help for usage information"
    exit 1
  end
end

# Run analysis if this file is executed directly
if __FILE__ == $PROGRAM_NAME
  target_dir = options[:target_dir]
  check_cmd = target_dir ? "git -C \"#{target_dir}\" rev-parse --git-dir > /dev/null 2>&1" : 'git rev-parse --git-dir > /dev/null 2>&1'

  unless system(check_cmd)
    puts "❌ Error: Not in a git repository#{target_dir ? " (#{target_dir})" : ''}"
    exit 1
  end

  analyzer = GitFileFrequencyAnalyzer.new(**options)
  analyzer.analyze
end
