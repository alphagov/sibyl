require "common"
require "sibyl/graph"

describe "Graph" do
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

  it "should be valid" do
    g = graph(%{
      step number a
        go -> b
      outcome b
    })

    assert g.valid?
  end

  it "should be invalid if a step is unreachable"
  it "should be invalid if a target is unresolved"
  it "should be invalid if there are no steps"
end
