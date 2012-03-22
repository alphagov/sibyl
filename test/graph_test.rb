require "common"
require "sibyl/graph"

describe "Graph validation" do
  def graph(source)
    Sibyl::Graph.new(source)
  end

  it "should translate a metadata line" do
    g = graph(%{
      metadata ivalue 1660
      metadata svalue "foo bar"
    })

    expected = {
      ivalue: 1660,
      svalue: "foo bar"
    }

    assert_equal expected, g.metadata
  end

  it "should walk the nodes according to inputs" do
    g = graph(%{
      step multiple "Yes or no?"
        option yes -> "How old are you?"
        option no -> "Whatever"
      step number "How old are you?"
        go ->
          if { input > 18 } -> "Adult"
          otherwise -> "Child"
      outcome "Whatever"
      outcome "Adult"
      outcome "Child"
    })

    assert_equal "How old are you?", g.at(["yes"]).name
    assert_equal "Adult", g.at(["yes", 19]).name
  end

  it "should raise an exception when inputs exceed steps" do
    g = graph(%{
      step number a
        go -> b
      outcome b
    })

    assert_raises Sibyl::InvalidInput do
      g.at([1, 2])
    end
  end
end
