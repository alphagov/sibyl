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
end
