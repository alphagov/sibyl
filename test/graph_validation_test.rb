require "common"
require "sibyl/graph"

describe "Graph validation" do
  def graph(source)
    Sibyl::Graph.new(source)
  end

  it "should be valid" do
    g = graph(%{
      step number a
        go -> b
      outcome b
    })

    assert g.valid?
  end

  it "should be invalid if a step is unreachable" do
    g = graph(%{
      step number a
        go -> c
      step number b
        go -> c
      outcome c
    })

    refute g.valid?
  end

  it "should be invalid if a target is unresolved" do
    g = graph(%{
      step option a
        option foo -> b
        option bar -> c
      outcome b
    })

    refute g.valid?
  end

  it "should be invalid if there are no steps" do
    g = graph("")

    refute g.valid?
  end
end
