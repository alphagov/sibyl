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

    g.validate!
  end

  it "should be invalid if a step is unreachable" do
    g = graph(%{
      step number a
        go -> c
      step number b
        go -> c
      outcome c
    })

    assert_raises Sibyl::InvalidGraph do
      g.validate!
    end
  end

  it "should be invalid if a target is unresolved" do
    g = graph(%{
      step multiple a
        option foo -> b
        option bar -> c
      outcome b
    })

    assert_raises Sibyl::InvalidGraph do
      g.validate!
    end
  end

  it "should be invalid if there are no steps" do
    g = graph("")

    assert_raises Sibyl::InvalidGraph do
      g.validate!
    end
  end

  it "should be invalid if there are cycles" do
    g = graph(%{
      step multiple a
        option foo -> b
        option bar -> c
      step number b
        go -> a
      outcome c
    })

    assert_raises Sibyl::InvalidGraph do
      g.validate!
    end
  end

  it "should be invalid if a multiple step has no options" do
    g = graph(%{
      step number a
        go -> c
      step multiple b
      outcome c
    })

    assert_raises Sibyl::InvalidGraph do
      g.validate!
    end
  end

  it "should be invalid if a multiple step has a go" do
    g = graph(%{
      step multiple a
        option foo -> b
        go -> c
      outcome b
      outcome c
    })

    assert_raises Sibyl::InvalidGraph do
      g.validate!
    end
  end

  it "should be invalid if a non-multiple step has options" do
    g = graph(%{
      step number a
        option foo -> b
      outcome b
    })

    assert_raises Sibyl::InvalidGraph do
      g.validate!
    end
  end

  it "should be invalid if a step has no go declarations" do
    g = graph(%{
      step number a
    })

    assert_raises Sibyl::InvalidGraph do
      g.validate!
    end
  end
end
