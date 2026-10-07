# frozen_string_literal: true

require "minitest/autorun"
require_relative "pr_digest"

class DiffParserTest < Minitest::Test
  def test_parses_path_and_line_counts_for_a_modified_file
    diff = <<~DIFF
      diff --git a/app/models/payment_authorisation.rb b/app/models/payment_authorisation.rb
      index 1111111..2222222 100644
      --- a/app/models/payment_authorisation.rb
      +++ b/app/models/payment_authorisation.rb
      @@ -10,6 +10,8 @@ class PaymentAuthorisation < ApplicationRecord
         aasm do
           state :held
      +    state :unreconciled
      +
      -    state :legacy
         end
    DIFF

    files = ReadPr::DiffParser.new(diff).files

    assert_equal 1, files.length
    assert_equal "app/models/payment_authorisation.rb", files.first.path
    assert_equal 2, files.first.additions
    assert_equal 1, files.first.deletions
    assert_equal :modified, files.first.status
  end
end

class DiffParserStatusTest < Minitest::Test
  def test_marks_a_new_file_as_added
    diff = <<~DIFF
      diff --git a/spec/models/payment_authorisation_spec.rb b/spec/models/payment_authorisation_spec.rb
      new file mode 100644
      index 0000000..abc1234
      --- /dev/null
      +++ b/spec/models/payment_authorisation_spec.rb
      @@ -0,0 +1,2 @@
      +RSpec.describe PaymentAuthorisation do
      +end
    DIFF

    file = ReadPr::DiffParser.new(diff).files.first

    assert_equal "spec/models/payment_authorisation_spec.rb", file.path
    assert_equal :added, file.status
    assert_equal 2, file.additions
    assert_equal 0, file.deletions
  end
end

class DiffParserDeletedTest < Minitest::Test
  def test_takes_the_path_from_the_old_side_when_a_file_is_deleted
    diff = <<~DIFF
      diff --git a/app/components/pricing_schedule_line_component.rb b/app/components/pricing_schedule_line_component.rb
      deleted file mode 100644
      index abc1234..0000000
      --- a/app/components/pricing_schedule_line_component.rb
      +++ /dev/null
      @@ -1,3 +0,0 @@
      -class PricingScheduleLineComponent
      -end
    DIFF

    file = ReadPr::DiffParser.new(diff).files.first

    assert_equal "app/components/pricing_schedule_line_component.rb", file.path
    assert_equal :deleted, file.status
    assert_equal 2, file.deletions
  end
end

class DiffParserRenameTest < Minitest::Test
  def test_reads_the_new_path_from_a_pure_rename_with_no_hunks
    diff = <<~DIFF
      diff --git a/app/mediators/settle_preauth_hold_action.rb b/app/mediators/capture_preauth_hold_action.rb
      similarity index 100%
      rename from app/mediators/settle_preauth_hold_action.rb
      rename to app/mediators/capture_preauth_hold_action.rb
    DIFF

    file = ReadPr::DiffParser.new(diff).files.first

    assert_equal "app/mediators/capture_preauth_hold_action.rb", file.path
    assert_equal :renamed, file.status
    assert_equal 0, file.additions
    assert_equal 0, file.deletions
  end
end

class DiffParserAddedLinesTest < Minitest::Test
  def test_exposes_added_lines_without_their_diff_marker
    diff = <<~DIFF
      diff --git a/app/models/payment_authorisation.rb b/app/models/payment_authorisation.rb
      --- a/app/models/payment_authorisation.rb
      +++ b/app/models/payment_authorisation.rb
      @@ -10,6 +10,7 @@ class PaymentAuthorisation < ApplicationRecord
         aasm do
      +    state :unreconciled
      -    state :legacy
         end
    DIFF

    file = ReadPr::DiffParser.new(diff).files.first

    assert_equal ["    state :unreconciled"], file.added_lines
  end
end

class SymbolExtractorRubyTest < Minitest::Test
  def test_extracts_class_module_and_method_names_from_ruby
    lines = [
      "module PaymentOperations",
      "  class CapturedPayment",
      "    def self.from_response(response)",
      "    def captured?",
      "      other_call(1)",
      "    end"
    ]

    assert_equal(
      %w[PaymentOperations CapturedPayment from_response captured?],
      ReadPr::SymbolExtractor.new("app/services/payment_operations/captured_payment.rb").defines(lines)
    )
  end
end

class SymbolExtractorDslTest < Minitest::Test
  def test_extracts_declarative_dsl_symbols_and_constants_from_ruby
    lines = [
      "    state :unreconciled",
      "    event :mark_unreconciled do",
      "  scope :active, -> { where(active: true) }",
      "  RETRY_LIMIT = 3",
      "    transitions from: :held, to: :unreconciled"
    ]

    assert_equal(
      [":unreconciled", ":mark_unreconciled", ":active", "RETRY_LIMIT"],
      ReadPr::SymbolExtractor.new("app/models/payment_authorisation.rb").defines(lines)
    )
  end
end

class SymbolExtractorTypescriptTest < Minitest::Test
  def test_extracts_exported_declarations_from_typescript
    lines = [
      "export default class TariffSidepanelController extends Controller {",
      "  export function buildSchedule(rows: Row[]) {",
      "export const PRICING_MODES = ['tou', 'flat']",
      "export interface ScheduleLine {",
      "export type Mode = 'tou' | 'flat'",
      "  private helper() {"
    ]

    assert_equal(
      %w[TariffSidepanelController buildSchedule PRICING_MODES ScheduleLine Mode],
      ReadPr::SymbolExtractor.new("app/javascript/controllers/tariff_sidepanel_controller.ts").defines(lines)
    )
  end
end

class RefLinkerTest < Minitest::Test
  def defines_by_path
    {
      "app/models/payment_authorisation.rb" => [":unreconciled", "mark_unreconciled"],
      "app/services/payment_operations/captured_payment.rb" => ["CapturedPayment"]
    }
  end

  def test_reports_names_defined_by_another_changed_file
    lines = [
      "  authorisation.mark_unreconciled!",
      "  CapturedPayment.from_response(response)"
    ]

    assert_equal(
      %w[mark_unreconciled CapturedPayment],
      ReadPr::RefLinker.new(defines_by_path).references_in("app/mediators/capture_preauth_hold_action.rb", lines)
    )
  end

  def test_does_not_report_a_file_referencing_its_own_declarations
    lines = ["    transitions from: :held, to: :unreconciled"]

    assert_empty ReadPr::RefLinker.new(defines_by_path).references_in("app/models/payment_authorisation.rb", lines)
  end
end

class SpecPairingTest < Minitest::Test
  def test_maps_a_rails_spec_to_its_subject
    assert_equal "app/models/payment_authorisation.rb",
                 ReadPr::SpecPairing.subject_of("spec/models/payment_authorisation_spec.rb")
  end

  def test_maps_an_engine_spec_to_its_subject
    assert_equal "engines/graphqlfox/app/graphql/types/tariff_type.rb",
                 ReadPr::SpecPairing.subject_of("engines/graphqlfox/spec/graphql/types/tariff_type_spec.rb")
  end

  def test_maps_a_typescript_test_to_its_subject
    assert_equal "app/components/pages/tariff/sidepanel_controller.ts",
                 ReadPr::SpecPairing.subject_of("spec/components/pages/tariff/sidepanel_controller.test.ts")
  end

  def test_returns_nil_for_a_file_that_is_not_a_test
    assert_nil ReadPr::SpecPairing.subject_of("app/models/payment_authorisation.rb")
  end
end

class NoiseClassifierTest < Minitest::Test
  def change(path:, status: :modified, added: [], removed: [])
    ReadPr::FileChange.new(
      path: path, status: status, additions: added.length, deletions: removed.length,
      added_lines: added, removed_lines: removed
    )
  end

  def test_treats_generated_and_lock_files_as_noise
    %w[
      Gemfile.lock yarn.lock package-lock.json db/schema.rb
      engines/graphqlfox/schema.graphql app/javascript/__snapshots__/tariff.test.ts.snap
    ].each do |path|
      assert ReadPr::NoiseClassifier.noise?(change(path: path, added: ["x"])), "expected #{path} to be noise"
    end
  end

  def test_treats_a_hand_written_source_file_as_signal
    refute ReadPr::NoiseClassifier.noise?(change(path: "app/models/payment_authorisation.rb", added: ["x"]))
  end
end

class NoiseClassifierMovementTest < NoiseClassifierTest
  def test_treats_a_pure_rename_as_noise
    assert ReadPr::NoiseClassifier.noise?(
      change(path: "app/mediators/capture_preauth_hold_action.rb", status: :renamed)
    )
  end

  def test_treats_a_rename_carrying_edits_as_signal
    refute ReadPr::NoiseClassifier.noise?(
      change(path: "app/mediators/capture_preauth_hold_action.rb", status: :renamed,
             added: ["  def call"], removed: ["  def perform"])
    )
  end

  def test_treats_a_reindent_with_no_change_in_content_as_noise
    assert ReadPr::NoiseClassifier.noise?(
      change(path: "app/models/payment_authorisation.rb",
             added: ["    state :held", "  end"], removed: ["  state  :held", "end"])
    )
  end
end

class DiffParserRemovedLinesTest < Minitest::Test
  def test_exposes_removed_lines_without_their_diff_marker
    diff = <<~DIFF
      diff --git a/app/models/payment_authorisation.rb b/app/models/payment_authorisation.rb
      --- a/app/models/payment_authorisation.rb
      +++ b/app/models/payment_authorisation.rb
      @@ -10,6 +10,7 @@ class PaymentAuthorisation < ApplicationRecord
      +    state :unreconciled
      -    state :legacy
    DIFF

    assert_equal ["    state :legacy"], ReadPr::DiffParser.new(diff).files.first.removed_lines
  end
end

class OrdererTest < Minitest::Test
  def record(path, defines: [], refs: [], noise: false)
    ReadPr::Record.new(path: path, defines: defines, refs: refs, noise: noise)
  end

  # Shaped after PR #8015, whose GitHub order interleaves mediators, models and
  # services and then dumps every spec at the end.
  def records
    [
      record("app/mediators/place_preauth_hold_action.rb"),
      record("app/mediators/release_stranded_preauth_hold_action.rb", refs: [":unreconciled"]),
      record("app/models/payment_authorisation.rb", defines: [":unreconciled"]),
      record("app/services/payment_operations/pin_preauth.rb", refs: [":unreconciled"]),
      record("spec/mediators/release_stranded_preauth_hold_action_spec.rb"),
      record("spec/models/payment_authorisation_spec.rb"),
      record("spec/services/payment_operations/pin_preauth_spec.rb"),
      record("Gemfile.lock", noise: true)
    ]
  end

  # place_preauth mentions nothing the change introduces, so it trails the two
  # files that do; every spec still travels with its subject.
  def test_leads_with_the_new_state_then_its_users_then_the_unconnected_file
    assert_equal(
      [
        "app/models/payment_authorisation.rb",
        "spec/models/payment_authorisation_spec.rb",
        "app/services/payment_operations/pin_preauth.rb",
        "spec/services/payment_operations/pin_preauth_spec.rb",
        "app/mediators/release_stranded_preauth_hold_action.rb",
        "spec/mediators/release_stranded_preauth_hold_action_spec.rb",
        "app/mediators/place_preauth_hold_action.rb",
        "Gemfile.lock"
      ],
      ReadPr::Orderer.new(records).ordered.map(&:path)
    )
  end
end

class AnchorTest < Minitest::Test
  def test_builds_the_github_file_fragment_from_the_path_digest
    assert_equal "diff-e1a315ff8b44c8984427f1452f97a6c0808dea7e6501a4c15083ed0c1f5b14b0",
                 ReadPr::Anchor.for("app/models/payment_authorisation.rb")
  end
end

class BuilderTest < Minitest::Test
  DIFF = <<~DIFF
    diff --git a/spec/models/payment_authorisation_spec.rb b/spec/models/payment_authorisation_spec.rb
    --- a/spec/models/payment_authorisation_spec.rb
    +++ b/spec/models/payment_authorisation_spec.rb
    @@ -1,2 +1,3 @@
    +  it { is_expected.to transition_from(:held).to(:unreconciled) }
    diff --git a/app/models/payment_authorisation.rb b/app/models/payment_authorisation.rb
    --- a/app/models/payment_authorisation.rb
    +++ b/app/models/payment_authorisation.rb
    @@ -10,6 +10,7 @@ class PaymentAuthorisation < ApplicationRecord
    +    state :unreconciled
    diff --git a/app/jobs/sweep_holds_job.rb b/app/jobs/sweep_holds_job.rb
    --- a/app/jobs/sweep_holds_job.rb
    +++ b/app/jobs/sweep_holds_job.rb
    @@ -4,3 +4,4 @@ class SweepHoldsJob
    +      hold.update!(status: :unreconciled)
  DIFF

  def digest
    ReadPr::Builder.new(diff: DIFF, source: ReadPr::PullRequest.new("chargefox/chargefox", 8015)).to_h
  end

  def test_orders_the_definition_then_its_spec_then_the_file_that_mentions_it
    assert_equal(
      [
        "app/models/payment_authorisation.rb",
        "spec/models/payment_authorisation_spec.rb",
        "app/jobs/sweep_holds_job.rb"
      ],
      digest[:files].map { |file| file[:path] }
    )
  end

  def test_carries_the_structural_facts_for_each_file
    model = digest[:files].first

    assert_equal 1, model[:additions]
    assert_equal 0, model[:deletions]
    assert_equal "modified", model[:status]
    assert_equal [":unreconciled"], model[:defines]
    assert_empty model[:refs]
    refute model[:noise]
  end

  def test_gives_each_file_a_deep_link_into_the_pull_request
    assert_equal(
      "https://github.com/chargefox/chargefox/pull/8015/files#diff-#{ReadPr::Anchor.for('app/jobs/sweep_holds_job.rb').delete_prefix('diff-')}",
      digest[:files].last[:url]
    )
  end

  def test_records_which_file_mentions_the_new_name
    job = digest[:files].last

    assert_equal "app/jobs/sweep_holds_job.rb", job[:path]
    assert_equal [":unreconciled"], job[:refs]
  end
end

class PullRequestTest < Minitest::Test
  def test_reads_repo_and_number_from_a_pull_request_url
    target = ReadPr::PullRequest.parse("https://github.com/chargefox/chargefox/pull/8015/files#diff-abc")

    assert_equal "chargefox/chargefox", target.repo
    assert_equal 8015, target.number
  end

  def test_returns_nothing_for_an_argument_that_is_not_a_url
    assert_nil ReadPr::PullRequest.parse("8015")
  end
end

class RefLinkerLinkabilityTest < Minitest::Test
  # Names like `error` or `expire` occur in half the files in any diff, so
  # linking on them fabricates dependencies and corrupts the ordering.
  def test_ignores_declarations_too_generic_to_identify_their_source
    defines_by_path = { "app/services/payment_operations/pin_preauth.rb" => %w[error expire give_up captured?] }
    lines = ["    raise error unless expire || give_up || captured?"]

    assert_empty ReadPr::RefLinker.new(defines_by_path).references_in("app/models/payment_authorisation.rb", lines)
  end

  def test_still_links_symbols_constants_and_compound_method_names
    defines_by_path = {
      "app/models/payment_authorisation.rb" => [":unreconciled", "CapturedPayment", "mark_unreconciled"]
    }
    lines = ["  CapturedPayment.new(state: :unreconciled).mark_unreconciled!"]

    assert_equal(
      [":unreconciled", "CapturedPayment", "mark_unreconciled"],
      ReadPr::RefLinker.new(defines_by_path).references_in("app/jobs/sweep_holds_job.rb", lines)
    )
  end
end

class OrdererSiblingPairingTest < OrdererTest
  # A ViewComponent spec covers the whole component; the PR may only touch its
  # template or stylesheet, leaving no same-extension subject to pair with.
  def test_pairs_a_spec_with_a_subject_that_differs_only_in_extension
    records = [
      record("spec/components/tariff/pricing_line_component_spec.rb"),
      record("app/components/tariff/pricing_line_component.html.erb"),
      record("app/components/tariff/pricing_line_component.scss")
    ]

    assert_equal(
      [
        "app/components/tariff/pricing_line_component.html.erb",
        "spec/components/tariff/pricing_line_component_spec.rb",
        "app/components/tariff/pricing_line_component.scss"
      ],
      ReadPr::Orderer.new(records).ordered.map(&:path)
    )
  end
end

class SpecPairingNestedRootTest < Minitest::Test
  def test_maps_a_spec_under_any_package_root_to_its_subject
    assert_equal "packs/ocpp/app/services/ocpp/v1/boot_notification/handler.rb",
                 ReadPr::SpecPairing.subject_of("packs/ocpp/spec/services/ocpp/v1/boot_notification/handler_spec.rb")
  end

  def test_does_not_mistake_a_nested_spec_directory_for_the_spec_root
    assert_equal "app/services/spec/report.rb",
                 ReadPr::SpecPairing.subject_of("spec/services/spec/report_spec.rb")
  end
end

class NoiseClassifierGeneratedTodoTest < NoiseClassifierTest
  def test_treats_packwerk_generated_todo_files_as_noise
    assert ReadPr::NoiseClassifier.noise?(change(path: "packs/ocpp/package_todo.yml", added: ["  - x"]))
  end

  def test_treats_a_hand_written_package_manifest_as_signal
    refute ReadPr::NoiseClassifier.noise?(change(path: "packs/ocpp/package.yml", added: ["  - x"]))
  end
end

class OrdererOrphanSpecTest < OrdererTest
  # A spec whose subject is untouched still belongs where its subject's layer
  # would put it, not lumped in with unrecognised paths.
  def test_ranks_a_spec_with_no_changed_subject_by_the_layer_it_covers
    records = [
      record("spec/components/foo_component_spec.rb"),
      record("spec/models/bar_spec.rb"),
      record("app/models/baz.rb")
    ]

    assert_equal(
      ["app/models/baz.rb", "spec/models/bar_spec.rb", "spec/components/foo_component_spec.rb"],
      ReadPr::Orderer.new(records).ordered.map(&:path)
    )
  end
end

class GraphTest < Minitest::Test
  def record(path, defines: [], refs: [])
    ReadPr::Record.new(path: path, defines: defines, refs: refs, noise: false)
  end

  # job → action → payment; the model is mentioned but mentions nothing.
  def records
    [
      record("app/jobs/charge_customer_job.rb", defines: ["capture_hold"], refs: ["CapturePreauthHoldAction"]),
      record("app/mediators/capture_preauth_hold_action.rb",
             defines: ["CapturePreauthHoldAction"], refs: %w[capture_hold capturable_for?]),
      record("app/models/payment_authorisation.rb", defines: ["capturable_for?"]),
      record("app/services/lonely.rb", defines: ["nobody_calls_this"])
    ]
  end

  def graph = ReadPr::Graph.new(records)

  def test_nothing_mentions_the_entry_point_but_it_mentions_others
    assert_equal :entry, graph.role("app/jobs/charge_customer_job.rb")
  end

  def test_a_file_that_is_mentioned_but_mentions_nothing_is_foundation
    assert_equal :foundation, graph.role("app/models/payment_authorisation.rb")
  end

  def test_a_file_on_both_sides_is_part_of_the_flow
    assert_equal :flow, graph.role("app/mediators/capture_preauth_hold_action.rb")
  end

  def test_a_file_connected_to_nothing_is_isolated
    assert_equal :isolated, graph.role("app/services/lonely.rb")
  end

  def test_reports_both_directions_of_the_reference
    assert_equal ["app/mediators/capture_preauth_hold_action.rb"],
                 graph.mentions("app/jobs/charge_customer_job.rb")
    assert_equal ["app/jobs/charge_customer_job.rb"],
                 graph.mentioned_by("app/mediators/capture_preauth_hold_action.rb")
  end
end

class JourneyOrderTest < GraphTest
  def test_reads_new_state_first_then_the_entry_point_then_the_flow_it_drives
    assert_equal(
      [
        "app/models/payment_authorisation.rb",
        "app/jobs/charge_customer_job.rb",
        "app/mediators/capture_preauth_hold_action.rb",
        "app/services/lonely.rb"
      ],
      ReadPr::JourneyOrder.new(records).ordered.map(&:path)
    )
  end
end

class BuilderRoleTest < BuilderTest
  def role_of(path) = digest[:files].find { |file| file[:path] == path }[:role]

  def test_labels_each_file_by_its_position_in_the_reference_graph
    assert_equal "foundation", role_of("app/models/payment_authorisation.rb")
    assert_equal "entry", role_of("app/jobs/sweep_holds_job.rb")
    assert_equal "test", role_of("spec/models/payment_authorisation_spec.rb")
  end

  def test_names_the_files_that_mention_each_one
    model = digest[:files].find { |file| file[:path] == "app/models/payment_authorisation.rb" }

    assert_equal ["app/jobs/sweep_holds_job.rb"], model[:mentioned_by]
  end
end

class BuilderWorkingTreeTest < Minitest::Test
  def digest
    ReadPr::Builder.new(diff: BuilderTest::DIFF, source: ReadPr::WorkingTree.new("abc1234")).to_h
  end

  def test_describes_the_source_as_a_working_tree_against_its_base
    assert_equal({ kind: "working_tree", base: "abc1234" }, digest[:source])
  end

  def test_offers_no_link_when_there_is_no_files_tab_to_anchor_to
    assert(digest[:files].all? { |file| file[:url].nil? })
  end

  def test_orders_and_annotates_exactly_as_it_would_for_a_pull_request
    assert_equal(
      ["app/models/payment_authorisation.rb", "spec/models/payment_authorisation_spec.rb",
       "app/jobs/sweep_holds_job.rb"],
      digest[:files].map { |file| file[:path] }
    )
    assert_equal "entry", digest[:files].last[:role]
  end
end

class GraphEntryTest < Minitest::Test
  def record(path, defines: [], refs: [])
    ReadPr::Record.new(path: path, defines: defines, refs: refs, noise: false)
  end

  # Nothing mentions a constants file either, but it is not where a journey
  # starts — only a job, controller or the like earns that label.
  def records
    [
      record("app/services/refusal_reasons.rb", refs: ["bad_authorisation?"]),
      record("app/services/pin_error_result.rb", defines: ["bad_authorisation?"])
    ]
  end

  def test_does_not_call_an_unmentioned_service_an_entry_point
    assert_equal :flow, ReadPr::Graph.new(records).role("app/services/refusal_reasons.rb")
  end

  def test_still_walks_from_it_when_the_change_has_no_entry_layer_file
    assert_equal ["app/services/refusal_reasons.rb"], ReadPr::Graph.new(records).roots.map(&:path)
  end
end
