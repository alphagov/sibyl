require "common"
require "sibyl/parser"
require "sibyl/ruby_transform"
require "sibyl/errors"
require "ostruct"

describe "Step" do
  def ruby(source)
    parser = Sibyl::Parser.new
    transform = Sibyl::RubyTransform.new
    transform.apply(parser.parse(source)).first
  end

  it "should set a variable" do
    step = ruby(%{
      step number a
        set foo_bar { 1 + 2 }
        go -> b
    })

    context = OpenStruct.new
    step.compute(0, context)
    assert_equal 3, context.foo_bar
  end

  it "should list valid inputs for a multiple choice step" do
    step = ruby(%{
      step multiple a
        option yes -> b
        option no  -> c
    })

    assert_equal ["yes", "no"], step.inputs
    assert_equal "a", step.name
  end

  it "should list exits for a multiple choice step" do
    step = ruby(%{
      step multiple a
        option yes -> b
        option no  -> c
    })

    assert_equal ["b", "c"], step.exits
  end

  it "should list exits for a multiple choice step with logic" do
    step = ruby(%{
      step multiple a
        option yes ->
          if { logic } -> b
          otherwise -> c
        option no -> d
    })

    assert_equal ["b", "c", "d"], step.exits
  end

  it "should list exits for a direct transition step" do
    step = ruby(%{
      step salary a
        go -> b
    })

    assert_equal ["b"], step.exits
  end

  it "should list exits for a direct transition step with logic" do
    step = ruby(%{
      step salary a
        go ->
          if { logic } -> b
          otherwise -> c
    })

    assert_equal ["b", "c"], step.exits
  end

  it "should compute exit for a direct transition step" do
    step = ruby(%{
      step number a
        go -> b
    })

    assert_equal "b", step.compute(2, OpenStruct.new)
  end

  it "should compute exit for a direct transition step with logic" do
    step = ruby(%{
      step number a
        go ->
          if { input > 1 } -> b
          otherwise -> c
    })

    assert_equal "b", step.compute(2, OpenStruct.new)
    assert_equal "c", step.compute(1, OpenStruct.new)
  end

  it "should compute exit for a multiple choice step" do
    step = ruby(%{
      step number a
        option foo -> b
        option bar -> c
    })

    assert_equal "b", step.compute("foo", OpenStruct.new)
    assert_equal "c", step.compute("bar", OpenStruct.new)
  end

  it "should compute exit for a multiple choice step with logic" do
    step = ruby(%{
      step number a
        option foo ->
          if { 2 > 1 } -> b
          otherwise -> c
        option bar ->
          if { 2 < 1 } -> d
          otherwise -> e
    })

    assert_equal "b", step.compute("foo", OpenStruct.new)
    assert_equal "e", step.compute("bar", OpenStruct.new)
  end

  it "should raise an exception if a reject block fails" do
    step = ruby(%{
      step number a
        reject { input > 1 }   
        go -> b
    })

    assert_raises Sibyl::PreconditionFailed do
      step.compute(2, OpenStruct.new)
    end
    assert_equal "b", step.compute(1, OpenStruct.new)
  end

  it "should raise an exception if an invalid option is supplied" do
    step = ruby(%{
      step number a
        option foo -> b
        option bar -> c
    })

    assert_raises Sibyl::InvalidInput do
      step.compute "baz", OpenStruct.new
    end
  end
end

