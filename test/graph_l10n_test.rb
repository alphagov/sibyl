require "common"
require "sibyl/graph"

describe "Graph l10n" do
  def graph(source)
    Sibyl::Graph.new(source)
  end

  it "should list necessary l10n keys" do
    g = graph(%{
      step multiple "step 1"
        option yes -> "step 2"
        option no  -> "outcome 1"

      step salary "step 2"
        go ->
          if { input.per_week >= 102 } ->
            "outcome 2"
          otherwise -> "outcome 3"

      outcome "outcome 1"
      outcome "outcome 2"
      outcome "outcome 3"
    })

    expected = %w[
      step_1.title
      step_1.options.yes
      step_1.options.no
      step_2.title
      outcome_1.title
      outcome_2.title
      outcome_3.title
    ]
    assert_equal expected.sort, g.l10n_keys.sort
  end
end

