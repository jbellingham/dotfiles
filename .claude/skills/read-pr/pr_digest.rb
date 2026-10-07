# frozen_string_literal: true

require "digest"
require "json"
require "open3"

# Builds a structural digest of a pull request diff: which files changed, what
# they define, and which of them reference each other. Deliberately carries no
# judgement about the change — only facts checkable in the diff itself.
module ReadPr
  Error = Class.new(StandardError)

  # A single changed file within the diff.
  FileChange = Struct.new(:path, :additions, :deletions, :status, :added_lines, :removed_lines,
                          keyword_init: true)

  # Pulls the names a changed file introduces out of its added lines. Purely
  # textual: it recognises declaration syntax, it does not parse the language.
  class SymbolExtractor
    # Each pattern captures the declared name exactly as it should be reported —
    # a DSL declaration captures its leading colon, so ":held" stays a symbol.
    RUBY_DECLARATIONS = [
      /^\s*(?:class|module)\s+([A-Z][A-Za-z0-9_]*)/,
      /^\s*def\s+(?:self\.)?([a-z_][A-Za-z0-9_]*[?!=]?)/,
      /^\s*(?:state|event|scope|enum)\s+(:[a-z_][A-Za-z0-9_]*[?!]?)/,
      /^\s*([A-Z][A-Z0-9_]*[A-Z0-9])\s*=[^=~]/
    ].freeze

    TYPESCRIPT_DECLARATIONS = [
      /^\s*export\s+(?:default\s+)?(?:abstract\s+)?(?:async\s+)?
       (?:function|const|let|class|interface|type|enum)\s+([A-Za-z_$][\w$]*)/x
    ].freeze

    RUBY_EXTENSIONS = %w[.rb .rake .gemspec].freeze
    TYPESCRIPT_EXTENSIONS = %w[.ts .tsx .js .jsx .mjs].freeze

    # @param path [String] the changed file's path, used to pick a language
    def initialize(path)
      @path = path
    end

    # @param lines [Array<String>] added lines, diff marker already stripped
    # @return [Array<String>] declared names, in order of first appearance
    def defines(lines)
      lines.flat_map { |line| declarations_in(line) }.uniq
    end

    private

    # @return [Array<Regexp>] empty for languages we do not read
    def patterns
      extension = File.extname(@path)
      return RUBY_DECLARATIONS if RUBY_EXTENSIONS.include?(extension)
      return TYPESCRIPT_DECLARATIONS if TYPESCRIPT_EXTENSIONS.include?(extension)

      []
    end

    def declarations_in(line)
      patterns.filter_map { |pattern| line[pattern, 1] }
    end
  end

  # A pull request: the diff has a Files tab, so every file can be linked to.
  PullRequest = Struct.new(:repo, :number) do
    URL = %r{\Ahttps?://github\.com/(?<repo>[^/]+/[^/]+)/pull/(?<number>\d+)}

    # @param argument [String]
    # @return [PullRequest, nil] nil when the argument is not a pull request URL
    def self.parse(argument)
      match = URL.match(argument.to_s)
      new(match[:repo], match[:number].to_i) if match
    end

    def to_h = { kind: "pull_request", repo: repo, number: number, url: files_url }

    def files_url = "https://github.com/#{repo}/pull/#{number}/files"

    # @param path [String]
    # @return [String] a link to that file's diff
    def url_for(path) = "#{files_url}##{Anchor.for(path)}"
  end

  # A branch's own changes, with no pull request yet — so nothing to link to.
  WorkingTree = Struct.new(:base) do
    def to_h = { kind: "working_tree", base: base }

    # @return [nil] there is no Files tab to anchor to
    def url_for(_path) = nil
  end

  # Turns a pull request's diff into an ordered, fact-only digest: what changed,
  # what it declares, what mentions it, and where to read each file on GitHub.
  class Builder
    # @param diff [String] unified diff text
    # @param source [PullRequest, WorkingTree] where the diff came from
    def initialize(diff:, source:)
      @diff = diff
      @source = source
    end

    # @return [Hash] digest suitable for JSON serialisation
    def to_h
      { source: @source.to_h, files: ordered_files.map { |record| entry(record) } }
    end

    private

    def changes
      @changes ||= DiffParser.new(@diff).files
    end

    def defines_by_path
      @defines_by_path ||= changes.to_h do |change|
        [change.path, SymbolExtractor.new(change.path).defines(change.added_lines)]
      end
    end

    def linker
      @linker ||= RefLinker.new(defines_by_path)
    end

    def ordered_files
      Orderer.new(records).ordered
    end

    def record_for(change)
      Record.new(
        path: change.path,
        defines: defines_by_path.fetch(change.path),
        refs: linker.references_in(change.path, change.added_lines),
        noise: NoiseClassifier.noise?(change)
      )
    end

    def changes_by_path
      @changes_by_path ||= changes.to_h { |change| [change.path, change] }
    end

    def records
      @records ||= changes.map { |change| record_for(change) }
    end

    # The graph the ordering used: specs and generated files take no part in it.
    def subject_graph
      @subject_graph ||= Graph.new(
        records.reject { |record| record.noise || SpecPairing.subject_of(record.path) }
      )
    end

    # @return [String] where the file sits in the change: "generated", "test",
    #   or its position in the reference graph
    def role_of(record)
      return "generated" if record.noise
      return "test" if SpecPairing.subject_of(record.path)

      subject_graph.role(record.path).to_s
    end

    def entry(record)
      change = changes_by_path.fetch(record.path)
      {
        path: record.path,
        additions: change.additions,
        deletions: change.deletions,
        status: change.status.to_s,
        defines: record.defines,
        refs: record.refs,
        mentioned_by: subject_graph.mentioned_by(record.path),
        role: role_of(record),
        noise: record.noise,
        url: @source.url_for(record.path)
      }
    end
  end

  # GitHub addresses each file in a pull request's Files tab by a fragment
  # derived from the file's path.
  module Anchor
    # @param path [String]
    # @return [String] the `#diff-…` fragment, without the leading hash
    def self.for(path)
      "diff-#{Digest::SHA256.hexdigest(path)}"
    end
  end

  # One changed file reduced to the facts ordering needs.
  Record = Struct.new(:path, :defines, :refs, :noise, keyword_init: true)

  # Ranks a path by how early its layer belongs in a read-through: the things
  # that define state first, the things that render it last.
  module LayerRank
    # Ordered: a file's rank is its position here, so inserting a layer needs no
    # renumbering. Anything unrecognised sorts after all of them, and wiring
    # sorts after that.
    LAYERS = [
      %r{(\A|/)db/migrate/},
      %r{(\A|/)app/models/},
      %r{(\A|/)app/(services|queries|finders|serializers|policies|validators)/},
      %r{(\A|/)app/(mediators|commands|jobs|workers)/},
      %r{(\A|/)app/(graphql|controllers|channels|mailers)/},
      %r{(\A|/)app/(components|views|javascript|helpers)/}
    ].freeze

    WIRING = %r{\A(config|lib)/}

    UNRANKED = LAYERS.size

    # @param path [String]
    # @return [Integer] lower sorts earlier
    def self.of(path)
      LAYERS.find_index { |pattern| path.match?(pattern) } ||
        (path.match?(WIRING) ? UNRANKED + 1 : UNRANKED)
    end

    # Layers execution enters the system through. A job or controller is where a
    # journey starts even when something else in the change mentions it back.
    ENTRY_LAYERS = [
      %r{(\A|/)app/(jobs|workers|controllers|channels|mailers|graphql)/},
      %r{\Alib/tasks/}
    ].freeze

    # @param path [String]
    # @return [Boolean]
    def self.entry?(path)
      ENTRY_LAYERS.any? { |pattern| path.match?(pattern) }
    end

    # A spec ranks as the layer it covers, so one whose subject is untouched
    # still lands beside that layer instead of among unrecognised paths.
    #
    # @param records [Array<Record>]
    # @return [Array<Record>] sorted by layer, then path
    def self.sort(records)
      records.sort_by { |record| [of(SpecPairing.subject_of(record.path) || record.path), record.path] }
    end
  end

  # Puts changed files into a reading order: definitions before the code that
  # mentions them, each test beside its subject, generated files last.
  class Orderer
    # @param records [Array<Record>]
    def initialize(records)
      @records = records
    end

    # @return [Array<Record>] the same records, reordered
    def ordered
      subjects, specs = signal.partition { |record| SpecPairing.subject_of(record.path).nil? }
      covered = specs.group_by { |spec| subject_for(spec, subjects)&.path }
      sequence = JourneyOrder.new(subjects).ordered

      sequence.flat_map { |subject| [subject, *covered[subject.path]] } +
        LayerRank.sort(orphans(covered, sequence)) +
        LayerRank.sort(noise)
    end

    private

    def signal
      @records.reject(&:noise)
    end

    def noise
      @records.select(&:noise)
    end

    # Specs left over because the code they cover is not part of this change.
    def orphans(covered, sequence)
      paired = sequence.map(&:path)
      covered.reject { |path, _| paired.include?(path) }.values.flatten
    end

    # Prefers the subject at the exact expected path, then any changed file
    # sharing its stem — a component spec covers the template and stylesheet
    # too, and the PR may have touched only those.
    def subject_for(spec, subjects)
      wanted = SpecPairing.subject_of(spec.path)
      subjects.find { |subject| subject.path == wanted } ||
        subjects.find { |subject| SpecPairing.stem_of(subject.path) == SpecPairing.stem_of(wanted) }
    end
  end

  # Who uses whom within the change: file A mentions file B when A's changed
  # lines carry a name B declares. Textual, so it under-reports rather than
  # invents, and it can be cyclic when two files share a method name.
  class Graph
    # @param records [Array<Record>]
    def initialize(records)
      @records = records
      @paths = records.map(&:path)
    end

    # @param path [String]
    # @return [Array<String>] changed files this one names
    def mentions(path)
      @mentions ||= @records.to_h { |record| [record.path, targets_of(record)] }
      @mentions.fetch(path, [])
    end

    # @param path [String]
    # @return [Array<String>] changed files naming this one
    def mentioned_by(path)
      @mentioned_by ||= @paths.to_h { |candidate| [candidate, @paths.select { |other| mentions(other).include?(candidate) }] }
      @mentioned_by.fetch(path, [])
    end

    # @param path [String]
    # @return [Symbol] :entry, :flow, :foundation or :isolated
    def role(path)
      uses = mentions(path).any?
      used = mentioned_by(path).any?

      return :isolated unless uses || used
      return :entry if uses && LayerRank.entry?(path)
      return :foundation unless uses

      :flow
    end

    # Where a top-down read starts. Entry layers when the change has any;
    # otherwise whatever nothing else in the change mentions, which is as close
    # to a starting point as the diff can show.
    #
    # @return [Array<Record>]
    def roots
      entries = @records.select { |record| role(record.path) == :entry }
      return entries if entries.any?

      @records.select { |record| mentions(record.path).any? && mentioned_by(record.path).empty? }
    end

    private

    def targets_of(record)
      record.refs.filter_map { |name| declared_by[name] }.uniq - [record.path]
    end

    # @return [Hash{String => String}] declared name to the file declaring it;
    #   where two files declare the same name, the first in the input wins
    def declared_by
      @declared_by ||= @records.flat_map { |record| record.defines.map { |name| [name, record.path] } }
                               .group_by(&:first)
                               .transform_values { |pairs| pairs.first.last }
    end
  end

  # Orders files as the change reads: the state it introduces, then each place
  # execution enters, then the path it takes from there. Files connected to
  # nothing in the change trail behind, by layer.
  class JourneyOrder
    # @param records [Array<Record>]
    def initialize(records)
      @records = records
      @graph = Graph.new(records)
    end

    # @return [Array<Record>]
    def ordered
      read = with_role(:foundation)
      LayerRank.sort(@graph.roots).each { |root| read = walk(root, read) }
      read + LayerRank.sort(@records - read)
    end

    private

    def with_role(role)
      LayerRank.sort(@records.select { |record| @graph.role(record.path) == role })
    end

    # Depth-first from one file through everything it names. The already-read
    # guard is what keeps a reference cycle from recursing forever.
    def walk(record, read)
      return read if read.include?(record)

      LayerRank.sort(named_by(record)).reduce(read + [record]) { |seen, target| walk(target, seen) }
    end

    def named_by(record)
      @graph.mentions(record.path).filter_map { |path| @records.find { |candidate| candidate.path == path } }
    end
  end

  # Separates files worth reading from files worth skimming: generated output,
  # lockfiles, and edits that moved bytes without changing meaning.
  module NoiseClassifier
    GENERATED_PATHS = [
      %r{(\A|/)(Gemfile|yarn|package|pnpm|Cargo)\.lock\z},
      %r{(\A|/)package-lock\.json\z},
      %r{(\A|/)db/(schema|structure)\.(rb|sql)\z},
      /\.graphql\z/,
      %r{(\A|/)package_todo\.yml\z},
      %r{/__snapshots__/},
      /\.snap\z/
    ].freeze

    # @param file [FileChange]
    # @return [Boolean]
    def self.noise?(file)
      GENERATED_PATHS.any? { |pattern| file.path.match?(pattern) } ||
        pure_rename?(file) ||
        whitespace_only?(file)
    end

    def self.pure_rename?(file)
      file.status == :renamed && file.additions.zero? && file.deletions.zero?
    end

    def self.whitespace_only?(file)
      added = squeezed(file.added_lines)
      removed = squeezed(file.removed_lines)
      return false if added.empty? || removed.empty?

      added.tally == removed.tally
    end

    # @return [Array<String>] lines with all whitespace removed, blanks dropped
    def self.squeezed(lines)
      Array(lines).map { |line| line.gsub(/\s+/, "") }.reject(&:empty?)
    end

    private_class_method :pure_rename?, :whitespace_only?, :squeezed
  end

  # Maps a test file to the path of the code it covers, so the two can be read
  # together instead of a whole block of tests trailing the change.
  module SpecPairing
    RUBY_SPEC = %r{\A(?<prefix>(?:[^/]+/)*?)spec/(?<rest>.+)_spec\.rb\z}
    JS_TEST = %r{\A(?<prefix>(?:[^/]+/)*?)spec/(?<rest>.+)\.test\.(?<ext>[jt]sx?)\z}

    # @param path [String]
    # @return [String, nil] the subject's expected path, or nil if not a test
    def self.subject_of(path)
      if (match = RUBY_SPEC.match(path))
        "#{match[:prefix]}app/#{match[:rest]}.rb"
      elsif (match = JS_TEST.match(path))
        "#{match[:prefix]}app/#{match[:rest]}.#{match[:ext]}"
      end
    end

    # @param path [String]
    # @return [String] the path with every extension removed, so that
    #   `foo_component.html.erb` and `foo_component.rb` share one stem
    def self.stem_of(path)
      directory = File.dirname(path)
      base = File.basename(path).split(".").first
      directory == "." ? base : "#{directory}/#{base}"
    end
  end

  # Cross-links changed files: which of them mention a name that another
  # changed file declares. Textual matching, not resolution — a name shadowed
  # elsewhere in the codebase can produce a false link, so callers must present
  # the result as "mentions", never as "calls".
  class RefLinker
    # @param defines_by_path [Hash{String => Array<String>}] declared names per changed file
    def initialize(defines_by_path)
      @defines_by_path = defines_by_path
    end

    # @param path [String] the referencing file, excluded from its own results
    # @param lines [Array<String>] its added lines
    # @return [Array<String>] names declared by other changed files
    def references_in(path, lines)
      @defines_by_path.reject { |owner, _| owner == path }
                      .values
                      .flatten
                      .uniq
                      .select { |name| linkable?(name) }
                      .select { |name| lines.any? { |line| line.match?(occurrence_of(name)) } }
    end

    private

    # A name only identifies its source if it is distinctive. Declared symbols
    # and constants qualify; a bare `error` or `expire` occurs everywhere and
    # would fabricate a dependency wherever the word appears.
    MIN_METHOD_LENGTH = 8

    def linkable?(name)
      return true if name.start_with?(":")
      return true if name.match?(/\A[A-Z]/)

      name.length >= MIN_METHOD_LENGTH && name.include?("_")
    end

    def occurrence_of(name)
      /(?<![\w:])#{Regexp.escape(name)}(?![\w])/
    end
  end

  # Parses `git diff` / `gh pr diff` unified output into FileChange records.
  class DiffParser
    # @param diff [String] unified diff text
    def initialize(diff)
      @diff = diff
    end

    # @return [Array<FileChange>]
    def files
      @diff.split(/^diff --git /).reject(&:empty?).map { |section| parse(section) }
    end

    private

    def parse(section)
      lines = section.lines
      body = lines.drop_while { |line| !line.start_with?("@@") }
      FileChange.new(
        path: path_of(lines),
        additions: body.count { |line| line.start_with?("+") },
        deletions: body.count { |line| line.start_with?("-") },
        status: status_of(lines),
        added_lines: content(body, "+"),
        removed_lines: content(body, "-")
      )
    end

    # @return [Array<String>] hunk lines with the given marker, marker stripped
    def content(body, marker)
      body.select { |line| line.start_with?(marker) }.map { |line| line[1..].chomp }
    end

    def path_of(lines)
      new_side = marker(lines, "+++ ")
      return new_side if new_side

      renamed_to = lines.find { |line| line.start_with?("rename to ") }
      return renamed_to.delete_prefix("rename to ").strip if renamed_to

      marker(lines, "--- ").to_s
    end

    # @return [String, nil] the path named by a `+++ b/` or `--- a/` marker,
    #   or nil when that side of the diff is /dev/null
    def marker(lines, prefix)
      line = lines.find { |candidate| candidate.start_with?(prefix) }&.strip
      return nil if line.nil? || line.end_with?("/dev/null")

      line.delete_prefix(prefix).sub(%r{\A[ab]/}, "")
    end

    def status_of(lines)
      header = lines.take_while { |line| !line.start_with?("@@") }
      return :added if header.any? { |line| line.start_with?("new file mode") }
      return :deleted if header.any? { |line| line.start_with?("deleted file mode") }
      return :renamed if header.any? { |line| line.start_with?("rename to ") }

      :modified
    end
  end

  # Thin wrapper over the `gh` CLI.
  module Gh
    # @param args [Array<String>]
    # @return [String] stdout
    # @raise [Error] when gh exits non-zero
    def self.capture(*args)
      stdout, stderr, status = Open3.capture3("gh", *args)
      raise Error, stderr.strip unless status.success?

      stdout
    end

    # @return [String, nil] stdout, or nil when gh reported failure
    def self.try(*args)
      stdout, _stderr, status = Open3.capture3("gh", *args)
      status.success? ? stdout : nil
    end
  end

  # Thin wrapper over `git`.
  module Git
    # @raise [Error] when git exits non-zero
    def self.capture(*args)
      stdout, stderr, status = Open3.capture3("git", *args)
      raise Error, stderr.strip unless status.success?

      stdout
    end

    # `git diff` exits 1 when it finds differences and `merge-base` exits 1 when
    # there is no common ancestor; neither is an error worth raising on.
    #
    # @return [String, nil] stdout, or nil when git failed outright
    def self.try(*args)
      stdout, _stderr, status = Open3.capture3("git", *args)
      status.exitstatus.to_i <= 1 ? stdout : nil
    end
  end

  # Reads a branch's own changes straight from git, for work that has no pull
  # request yet: everything since the branch diverged, staged or not, plus the
  # files git is not tracking. Files marked skip-worktree stay invisible here,
  # exactly as they are to `git status`.
  module WorkingTreeDiff
    BASE_REFS = %w[origin/HEAD origin/master origin/main master main].freeze

    # @return [Array(String, String)] the unified diff, and the base it is against
    def self.capture
      base = merge_base
      [[Git.capture("diff", base, "--"), *untracked.map { |path| as_new_file(path) }].join, base]
    end

    # @return [String] the commit where this branch left the mainline
    # @raise [Error] when no candidate base branch exists
    def self.merge_base
      found = BASE_REFS.filter_map { |ref| Git.try("merge-base", "HEAD", ref)&.strip }.find { |sha| !sha.empty? }
      raise Error, "no base branch to diff against (tried #{BASE_REFS.join(', ')})" unless found

      found
    end

    def self.untracked
      Git.capture("ls-files", "--others", "--exclude-standard").lines.map(&:chomp).reject(&:empty?)
    end

    def self.as_new_file(path)
      Git.try("diff", "--no-index", "--", "/dev/null", path).to_s
    end

    private_class_method :merge_base, :untracked, :as_new_file
  end

  # Command-line entry point: resolve a pull request, print its digest as JSON.
  module CLI
    # @param argv [Array<String>]
    # @return [Integer] process exit status
    def self.run(argv)
      local = argv.include?("--local")
      puts JSON.pretty_generate(local ? working_tree : pull_request_or_working_tree(argv.grep_v(/\A--/).first))
      0
    rescue Error => e
      warn "read-pr: #{e.message}"
      1
    end

    # Falls back to the branch's own changes when it has no pull request yet.
    def self.pull_request_or_working_tree(argument)
      source = resolve(argument)
      return working_tree if source.nil?

      Builder.new(diff: Gh.capture("pr", "diff", source.number.to_s, "--repo", source.repo), source: source).to_h
    end

    def self.working_tree
      diff, base = WorkingTreeDiff.capture
      Builder.new(diff: diff, source: WorkingTree.new(base)).to_h
    end

    # @param argument [String, nil] a pull request URL, a number, or nothing
    # @return [PullRequest, nil] nil when the branch has no pull request
    def self.resolve(argument)
      return PullRequest.parse(argument) if PullRequest.parse(argument)
      return PullRequest.new(current_repo, Integer(argument)) if argument.to_s.match?(/\A\d+\z/)

      url = Gh.try("pr", "view", "--json", "url", "-q", ".url")
      url && PullRequest.parse(url.strip)
    end

    def self.current_repo
      Gh.capture("repo", "view", "--json", "nameWithOwner", "-q", ".nameWithOwner").strip
    end
  end
end

exit ReadPr::CLI.run(ARGV) if $PROGRAM_NAME == __FILE__
