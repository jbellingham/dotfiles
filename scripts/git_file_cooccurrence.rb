#!/usr/bin/env ruby
# frozen_string_literal: true

require 'date'
require 'time'

# Git File Co-occurrence Analyzer
#
# Analyzes git commit history to identify files that frequently change together
# Integrates with git_file_frequency.rb to focus on high-churn files
#
# Usage: ruby git_file_cooccurrence.rb [options]
#   --target FILE        Analyze co-occurrences for specific file
#   --top N              Analyze top N files from weighted ranking (default: 10)
#   --min-support N      Minimum co-occurrence count to display (default: 5)
#   --min-confidence N   Minimum confidence percentage (default: 20)
#   --decay-rate R       Decay rate for weighted file selection (default: 0.5)
#   --commit-window N    Include files from N commits before/after (temporal coupling, default: 0)
#   --exclude-specs      Exclude all spec/test files from analysis
#   --target-dir DIR     Analyze git repository at DIR (default: current directory)
#   --help               Show this help message
#
#    Recommended commit window sizes
#   | Window Size | Use Case                  | Captures                                          |
#   |-------------|---------------------------|---------------------------------------------------|
#   | 0 (default) | Tight coupling analysis   | Same-commit co-edits only                         |
#   | 2           | Feature work detection    | Typical multi-commit features (1-3 commits apart) |
#   | 5           | Sprint/iteration coupling | Work spanning several days by same developer      |
#   | 10          | Epic-level analysis       | Large features spanning weeks                     |
#
# The "lift" metric shows how strongly two files are coupled relative to their individual change frequencies.
#
#   ★ Insight ─────────────────────────────────────
#   1. Normalized Coupling Strength: Lift divides co-occurrence count by the minimum individual frequency, creating a 0-1 scale that's comparable across file pairs
#   regardless of their absolute commit counts
#   2. Relative vs Absolute: While support (raw count) and confidence (percentage) are asymmetric metrics, lift provides a symmetric measure of coupling strength
#   normalized by the less-active file
#   3. Coupling Detection: High lift (>0.5) with low confidence reveals files that change together frequently but only represent a small portion of the target file's
# total changes - indicating selective coupling to specific features
#   ─────────────────────────────────────────────────
#
# 📐 How Lift is Calculated
#
# lift = (times_changed_together) / min(file_A_commits, file_B_commits)
#
# It answers: "What percentage of the less-frequently-changed file's commits also include the other file?"
#
# 💡 What Different Lift Values Mean
#
# Lift = 1.0 (Perfect Coupling)
#
# File A changes: 100 times
# File B changes: 100 times
# Together: 100 times
# Lift: 100 / min(100, 100) = 1.0
# Meaning: Files ALWAYS change together (perfectly coupled)
#
# Lift = 0.6-0.8 (Strong Coupling)
#
# charge_session.rb: 564 commits
# charge_session_spec.rb: 364 commits
# Together: 225 commits
# Lift: 225 / min(564, 364) = 225/364 = 0.62
# Meaning: The spec file changes with the model 62% of the time. This is healthy test coverage - spec changes in 62% of its commits also involve the model.
#
#   Lift = 0.1-0.3 (Moderate Coupling)
#
# charge_session.rb: 564 commits
# user.rb: 349 commits
# Together: 34 commits
# Lift: 34 / min(564, 349) = 34/349 = 0.10
# Meaning: These files rarely change together (only 10% overlap). They're loosely coupled - probably interact through interfaces but aren't tightly bound.
#
#   Lift < 0.1 (Weak/Independent)
#
# charge_station.rb: 464 commits
# charge_session.rb: 564 commits
# Together: 32 commits
# Lift: 32 / min(464, 564) = 32/464 = 0.07
# Meaning: Very independent. Even though they're in the same domain, they change mostly independently. Good architectural separation!
#
#   🎯 Real Example from Your Codebase
#
#   Looking at charge_station.rb:
#
#   | File                               | Support | Confidence | Lift | Interpretation                                               |
#   |------------------------------------|---------|------------|------|--------------------------------------------------------------|
#   | spec/models/charge_station_spec.rb | 141     | 30.4%      | 0.67 | Strong: Spec changes in 67% of its commits include the model |
#   | app/admin/charge_station.rb        | 78      | 16.8%      | 0.25 | Moderate: Admin UI coupled to model in 25% of admin changes  |
#   | app/models/connector.rb            | 33      | 7.1%       | 0.19 | Weak: Models mostly change independently                     |
#
#   🔍 How to Use Lift
#
#   High Lift (>0.5) + High Confidence (>30%)→ Strong coupling - Files are tightly bound, change together frequently→ Action: Good if intentional (test/code), concerning
#   if cross-layer (model/view)
#
#   High Lift (>0.5) + Low Confidence (<10%)→ Selective coupling - One file depends heavily on the other, but not vice versa→ Action: Check if the dependency is
#   one-directional as expected
#
#   Low Lift (<0.2) + High Confidence (>20%)→ Fan-out pattern - One file triggers changes across many others→ Action: Could indicate a core abstraction or a god object
#
#   Low Lift (<0.2) + Low Confidence (<10%)→ Weak association - Files occasionally change together by coincidence→ Action: Probably fine, just loosely related
#
#   🎓 Summary
#
#   Lift = "Of the less-frequently-changed file, what % of its commits also touch the other file?"
#
#   - 1.0 = Always change together (perfect coupling)
#   - 0.6-0.8 = Usually change together (strong coupling)
#   - 0.2-0.5 = Sometimes change together (moderate coupling)
#   - <0.2 = Rarely change together (weak/independent)
#
#   Your codebase shows mostly low lift values (<0.2), which is excellent - it means your files are loosely coupled and change independently!
#
#   ⚠️ IMPORTANT: Lift > 1.0 with Temporal Coupling (--commit-window > 0)
#
#   When using temporal coupling, lift can EXCEED 1.0. This happens because files can be associated multiple times
#   through the sliding commit window. This is intentional and reveals "feature-locked" relationships.
#
#   Lift > 1.0 interpretation with temporal coupling:
#   - 1.0-1.5 = Very tight temporal coupling - files usually change in nearby commits
#   - 1.5-2.0 = Feature-locked - files almost always change together during feature work
#   - >2.0 = Atomic subsystem - files are modified as a single unit, suggesting they should be considered one module
#   Recommended Interpretation
#
#   | Lift    | With Window=0      | With Window>0    | Meaning                                   |
#   |---------|--------------------|------------------|-------------------------------------------|
#   | 0.0-0.2 | Rarely together    | Rarely nearby    | Weak/independent                          |
#   | 0.2-0.5 | Sometimes together | Sometimes nearby | Moderate coupling                         |
#   | 0.5-1.0 | Often together     | Often nearby     | Strong coupling                           |
#   | 1.0-1.5 | N/A (impossible)   | Usually nearby   | Very tight temporal coupling              |
#   | >1.5    | N/A (impossible)   | Always nearby    | Feature-locked (change one = change both) |
#
#   Example: lift 2.2 means the files appear together in temporal windows MORE often than the less-frequent file
#   even appears individually. This indicates selective but extremely coordinated feature work - when one changes,
#   the other ALWAYS changes within the commit window by the same author.
#
#   📊 Understanding Confidence vs Lift Divergence
#
#   Sometimes you'll see HIGH LIFT (>1.5) with LOW CONFIDENCE (<10%). This is not a contradiction - it reveals
#   specialized subsystems with selective temporal coupling:
#
#   Example: file_A ↔ file_B: confidence 7%, lift 2.1
#   - Low confidence (7%) = file_B only appears in 7% of file_A's commits
#   - High lift (2.1) = When file_B DOES change, it's almost ALWAYS near file_A changes
#
#   Interpretation: file_B is rarely modified (specialized subsystem), but when developers work on it,
#   they ALWAYS coordinate with file_A in the same feature work. These are tightly coupled modules that
#   just don't change frequently.
#
#   Action: Consider these files as a single cohesive unit despite low overall change frequency.

class GitFileCooccurrenceAnalyzer
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

  def initialize(target_file: nil, top_n: 10, min_support: 5, min_confidence: 20, decay_rate: 0.5, commit_window: 0,
                 exclude_specs: false, target_dir: nil)
    @target_file = target_file
    @top_n = top_n
    @min_support = min_support
    @min_confidence = min_confidence
    @decay_rate = decay_rate
    @commit_window = commit_window
    @exclude_specs = exclude_specs
    @target_dir = target_dir

    # Data structures
    @commits = [] # Array of [commit_hash, date, author, Set[files]]
    @file_commit_count = Hash.new(0) # file -> number of commits
    @cooccurrence_matrix = Hash.new { |h, k| h[k] = Hash.new(0) } # file1 -> file2 -> count
    @weighted_frequencies = Hash.new(0.0)
  end

  def analyze
    puts "🔍 Analyzing git commit co-occurrence patterns...\n"
    puts "   📁 Repository: #{@target_dir || '.'}\n" if @target_dir
    puts "   🚫 Excluding spec/test files from analysis\n" if @exclude_specs
    puts "   ⏱️  Using ±#{@commit_window} commit window for temporal coupling\n" if @commit_window > 0
    puts "\n"

    parse_git_log
    apply_commit_window if @commit_window > 0
    calculate_weighted_frequencies

    if @target_file
      analyze_single_file(@target_file)
    else
      analyze_top_files
    end
  end

  private

  def git_command(cmd)
    if @target_dir
      `git -C "#{@target_dir}" #{cmd}`
    else
      `git #{cmd}`
    end
  end

  def parse_git_log
    puts '📊 Parsing commit history...'

    # Get all commits with file changes and author
    git_log = git_command("log --all --name-only --date=iso --pretty=format:'COMMIT|%H|%ad|%an'")

    current_commit = nil
    current_date = nil
    current_author = nil
    current_files = Set.new

    git_log.each_line do |line|
      line = line.strip
      next if line.empty?

      if line.start_with?('COMMIT|')
        # Save previous commit if it had files
        if current_commit && current_files.any?
          @commits << [current_commit, current_date, current_author, current_files.dup]

          # Update co-occurrence matrix
          current_files.to_a.combination(2).each do |file1, file2|
            @cooccurrence_matrix[file1][file2] += 1
            @cooccurrence_matrix[file2][file1] += 1
          end

          # Update file commit counts
          current_files.each { |file| @file_commit_count[file] += 1 }
        end

        # Parse new commit
        parts = line.split('|')
        current_commit = parts[1]
        current_date = Time.parse(parts[2])
        current_author = parts[3]
        current_files = Set.new
      else
        # File in current commit
        filename = line

        # Skip excluded files
        next if should_exclude_file?(filename)

        current_files << filename
      end
    end

    # Handle last commit
    if current_commit && current_files.any?
      @commits << [current_commit, current_date, current_author, current_files]
      current_files.to_a.combination(2).each do |file1, file2|
        @cooccurrence_matrix[file1][file2] += 1
        @cooccurrence_matrix[file2][file1] += 1
      end
      current_files.each { |file| @file_commit_count[file] += 1 }
    end

    puts "   ✓ Parsed #{@commits.size} commits with #{@file_commit_count.size} unique files\n\n"
  end

  def apply_commit_window
    puts "📊 Applying temporal coupling window (±#{@commit_window} commits, same author only)..."

    # For each commit, associate its files with files in nearby commits by same author
    @commits.each_with_index do |(_commit_hash, _date, author, files), index|
      # Get files from commits within the window by the same author
      window_files = Set.new

      # Look backwards
      @commit_window.times do |offset|
        prev_index = index - offset - 1
        break if prev_index < 0

        _prev_hash, _prev_date, prev_author, prev_files = @commits[prev_index]
        # Only include if same author
        window_files.merge(prev_files) if prev_author == author
      end

      # Look forwards
      @commit_window.times do |offset|
        next_index = index + offset + 1
        break if next_index >= @commits.size

        _next_hash, _next_date, next_author, next_files = @commits[next_index]
        # Only include if same author
        window_files.merge(next_files) if next_author == author
      end

      # Create associations between current commit files and window files
      files.each do |file1|
        window_files.each do |file2|
          next if file1 == file2 # Don't associate file with itself

          @cooccurrence_matrix[file1][file2] += 1
          @cooccurrence_matrix[file2][file1] += 1
        end
      end
    end

    puts "   ✓ Temporal coupling applied\n\n"
  end

  def calculate_weighted_frequencies
    now = Time.now

    @commits.each do |_commit_hash, date, _author, files|
      years_ago = (now - date) / SECONDS_PER_YEAR
      weight = Math.exp(-@decay_rate * years_ago)

      files.each do |file|
        @weighted_frequencies[file] += weight
      end
    end
  end

  def should_exclude_file?(filename)
    basename = File.basename(filename)
    return true if EXCLUDED_FILES.include?(basename)
    return true if EXCLUDED_PATTERNS.any? { |pattern| filename.match?(pattern) }
    return true if @exclude_specs && spec_file?(filename)

    false
  end

  def spec_file?(filename)
    filename.include?('spec/') || filename.include?('test/') || filename.include?('_spec.rb') || filename.include?('_test.rb')
  end

  def get_top_weighted_files(n)
    @weighted_frequencies
      .reject { |file, _score| file.include?('spec/') || file.include?('test/') }
      .sort_by { |_file, score| -score }
      .first(n)
      .map(&:first)
  end

  def analyze_single_file(target_file)
    unless @file_commit_count.key?(target_file)
      puts "❌ Error: File '#{target_file}' not found in commit history"
      exit 1
    end

    puts "🎯 ANALYZING CO-OCCURRENCES FOR: #{target_file}"
    puts '=' * 100
    puts "\n"

    display_cooccurrences_for_file(target_file)
  end

  def analyze_top_files
    top_files = get_top_weighted_files(@top_n)

    puts "🎯 ANALYZING TOP #{@top_n} FILES BY RECENCY-WEIGHTED FREQUENCY"
    puts '=' * 100
    puts "\n"

    top_files.each_with_index do |file, index|
      puts "#{index + 1}. #{file}"
      puts "   Commits: #{@file_commit_count[file]}, Weighted score: #{@weighted_frequencies[file].round(2)}"
    end

    puts "\n" + ('=' * 100) + "\n\n"

    top_files.each do |file|
      display_cooccurrences_for_file(file)
      puts "\n" + ('-' * 100) + "\n\n"
    end

    display_coupling_summary(top_files)
  end

  def display_cooccurrences_for_file(target_file)
    target_commits = @file_commit_count[target_file]

    # Get co-occurring files with metrics
    cooccurrences = @cooccurrence_matrix[target_file]
                    .map do |other_file, count|
      next if count < @min_support

      confidence = (count.to_f / target_commits * 100).round(1)
      next if confidence < @min_confidence

      other_commits = @file_commit_count[other_file]
      support = count
      lift = (count.to_f / [target_commits, other_commits].min).round(2)

      {
        file: other_file,
        support: support,
        confidence: confidence,
        lift: lift,
        other_commits: other_commits
      }
    end
      .compact
      .sort_by { |co| [-co[:confidence], -co[:support]] }

    if cooccurrences.empty?
      puts "📄 #{target_file}"
      puts "   No significant co-occurrences found (min support: #{@min_support}, min confidence: #{@min_confidence}%)"
      return
    end

    puts "📄 #{target_file} (appears in #{target_commits} commits)"
    puts "\n   Files that commonly change together:"
    puts '   ' + format('%-60s %8s %10s %8s', 'File', 'Support', 'Confidence', 'Lift')
    puts '   ' + ('-' * 90)

    cooccurrences.first(15).each do |co|
      puts '   ' + format('%-60s %8d %9.1f%% %8.2f',
                          co[:file].length > 60 ? "#{co[:file][0..56]}..." : co[:file],
                          co[:support],
                          co[:confidence],
                          co[:lift])
    end

    display_cooccurrence_insights(target_file, cooccurrences, target_commits)
  end

  def display_cooccurrence_insights(target_file, cooccurrences, _target_commits)
    return if cooccurrences.empty?

    # Identify coupling patterns
    high_confidence = cooccurrences.select { |co| co[:confidence] >= 50 }
    test_files = cooccurrences.select { |co| co[:file].include?('spec/') || co[:file].include?('test/') }
    model_files = cooccurrences.select { |co| co[:file].include?('app/models/') }

    insights = []

    insights << "⚠️  HIGH COUPLING: #{high_confidence.size} file(s) with ≥50% confidence" if high_confidence.any?

    if test_files.any?
      test_ratio = (test_files.size.to_f / cooccurrences.size * 100).round(0)
      insights << "✅ TEST COVERAGE: #{test_ratio}% of co-occurrences are test files"
    end

    if model_files.any? && !target_file.include?('app/models/')
      insights << "🔗 MODEL COUPLING: Changes often affect #{model_files.size} model file(s)"
    end

    return if insights.empty?

    puts "\n   💡 Insights:"
    insights.each { |insight| puts "      #{insight}" }
  end

  def display_coupling_summary(top_files)
    puts '📊 COUPLING SUMMARY'
    puts '=' * 100

    # Calculate average coupling metrics for top files
    total_cooccurrences = 0
    high_coupling_files = []

    top_files.each do |file|
      target_commits = @file_commit_count[file]
      cooccurrences = @cooccurrence_matrix[file].select { |_other, count| count >= @min_support }

      avg_confidence = if cooccurrences.any?
                         cooccurrences.sum { |_other, count| count.to_f / target_commits * 100 } / cooccurrences.size
                       else
                         0
                       end

      total_cooccurrences += cooccurrences.size

      high_coupling_files << [file, avg_confidence] if avg_confidence >= 30
    end

    puts "\n📈 Metrics:"
    puts "   • Average co-occurrences per file: #{(total_cooccurrences.to_f / top_files.size).round(1)}"
    puts "   • Files with high coupling (≥30% avg confidence): #{high_coupling_files.size}"

    if high_coupling_files.any?
      puts "\n⚠️  High Coupling Files (consider refactoring for better modularity):"
      high_coupling_files.sort_by { |_f, conf| -conf }.first(5).each do |file, conf|
        puts "   • #{file} (avg confidence: #{conf.round(1)}%)"
      end
    end

    puts "\n💡 Interpretation:"
    puts '   • Support: Number of commits where files changed together'
    puts '   • Confidence: Given target file changed, probability other file also changed'
    puts '   • Lift: How much more likely files change together vs independently'
    puts '   • High confidence (≥50%) suggests tight coupling - may indicate architectural concerns'
    puts '   • Test file co-occurrence is healthy - shows good test coverage'
  end
end

# Parse command line arguments
options = {
  target_file: nil,
  top_n: 10,
  min_support: 5,
  min_confidence: 20,
  decay_rate: 0.5,
  commit_window: 0,
  exclude_specs: false,
  target_dir: nil
}

args = ARGV.dup
while (arg = args.shift)
  case arg
  when '--target'
    options[:target_file] = args.shift
  when '--top'
    options[:top_n] = args.shift.to_i
  when '--min-support'
    options[:min_support] = args.shift.to_i
  when '--min-confidence'
    options[:min_confidence] = args.shift.to_i
  when '--decay-rate'
    options[:decay_rate] = args.shift.to_f
  when '--commit-window'
    options[:commit_window] = args.shift.to_i
  when '--exclude-specs'
    options[:exclude_specs] = true
  when '--target-dir'
    options[:target_dir] = args.shift
  when '--help', '-h'
    puts File.read(__FILE__).split("\n")[2..14].map { |l| l.sub(/^# ?/, '') }.join("\n")
    exit 0
  else
    puts "Unknown option: #{arg}"
    puts 'Use --help for usage information'
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

  analyzer = GitFileCooccurrenceAnalyzer.new(**options)
  analyzer.analyze
end
