require "common"
require "sibyl"

describe "Parser" do
  it "should parse a metadata line with a number" do
    actual = Sibyl.parse(%{
      metadata need 1660
    })

    expected = [[:metadata, "need", 1660]]

    assert_equal expected, actual
  end

  it "should parse a metadata line with a word" do
    actual = Sibyl.parse(%{
      metadata foo bar-baz
    })

    expected = [[:metadata, "foo", "bar-baz"]]

    assert_equal expected, actual
  end

  it "should parse a metadata line with a string" do
    actual = Sibyl.parse(%{
      metadata foo "bar baz"
    })

    expected = [[:metadata, "foo", "bar baz"]]

    assert_equal expected, actual
  end

  it "should parse a simple multiple option step" do
    actual = Sibyl.parse(%{
      step multiple a
        option yes -> b
        option no  -> c
    })

    expected = [
      [:step, "multiple", "a", [
        [:option, :simple, "yes", "b"],
        [:option, :simple, "no", "c"]]]]

    assert_equal expected, actual
  end

  it "should parse a multiple option step with logic" do
    actual = Sibyl.parse(%{
      step multiple a
        option yes ->
          if { logic } -> b
          otherwise -> c
        option no -> d
    })

    expected = [
      [:step, "multiple", "a", [
        [:option, :branch, "yes", [
          [:if, "logic", "b"],
          [:otherwise, "c"]]],
        [:option, :simple, "no", "d"]]]]

    assert_equal expected, actual
  end

  it "should parse a step with a simple direct transition" do
    actual = Sibyl.parse(%{
      step salary a
        go -> b
    })

    expected = [
      [:step, "salary", "a", [
        [:go, :simple, "b"]]]]

    assert_equal expected, actual
  end

  it "should parse a step with a direct transition with logic" do
    actual = Sibyl.parse(%{
      step salary a
        go ->
          if { logic } -> b
          otherwise -> c
    })

    expected = [
      [:step, "salary", "a", [
        [:go, :branch, [
          [:if, "logic", "b"],
          [:otherwise, "c"]]]]]]

    assert_equal expected, actual
  end

  it "should parse an empty document" do
    actual = Sibyl.parse(%{
    })

    expected = []

    assert_equal expected, actual
  end

  it "should parse a reject block" do
    actual = Sibyl.parse(%{
      step any a
        reject { logic }
    })

    expected = [
      [:step, "any", "a", [
        [:reject, "logic"]]]]

    assert_equal expected, actual
  end

  it "should parse a set block" do
    actual = Sibyl.parse(%{
      step any a
        set foo_bar { input }
    })

    expected = [
      [:step, "any", "a", [
        [:set, "foo_bar", "input"]]]]

    assert_equal expected, actual
  end


  it "should ignore a comment inside a unit" do
    actual = Sibyl.parse(%{
      step any a
        -- ignore me
        go -> b
    })

    expected = [
      [:step, "any", "a", [
        [:go, :simple, "b"]]]]

    assert_equal expected, actual
  end

  it "should ignore a comment before a unit" do
    actual = Sibyl.parse(%{
      -- ignore me
      metadata foo bar
    })

    expected = [[:metadata, "foo", "bar"]]

    assert_equal expected, actual
  end
end
