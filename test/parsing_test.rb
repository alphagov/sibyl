require "common"
require "sibyl"

describe "Parser" do
  it "should parse a metadata line with a number" do
    rule = <<-END
      metadata need 1660
    END

    actual = Sibyl.parse(rule)
    expected = [[:metadata, "need", 1660]]

    assert_equal expected, actual
  end

  it "should parse a metadata line with a word" do
    rule = <<-END
      metadata foo bar-baz
    END

    actual = Sibyl.parse(rule)
    expected = [[:metadata, "foo", "bar-baz"]]

    assert_equal expected, actual
  end

  it "should parse a metadata line with a string" do
    rule = <<-end
      metadata foo "bar baz"
    end

    actual = Sibyl.parse(rule)
    expected = [[:metadata, "foo", "bar baz"]]

    assert_equal expected, actual
  end

  it "should ignore a comment before a unit" do
    rule = <<-end
      -- ignore me
      metadata foo bar
    end

    actual = Sibyl.parse(rule)
    expected = [[:metadata, "foo", "bar"]]

    assert_equal expected, actual
  end

  it "should parse a simple multiple option step" do
    rule = <<-END
      step multiple a
        option yes -> b
        option no  -> c
    END

    actual = Sibyl.parse(rule)
    expected = [
      [:step, "multiple", "a", [
        [:option, :simple, "yes", "b"],
        [:option, :simple, "no", "c"]]]]

    assert_equal expected, actual
  end

  it "should ignore a comment inside a unit" do
    rule = <<-end
      step multiple a
        -- ignore me
        option yes -> b
        option no  -> c
    end

    actual = Sibyl.parse(rule)
    expected = [
      [:step, "multiple", "a", [
        [:option, :simple, "yes", "b"],
        [:option, :simple, "no", "c"]]]]

    assert_equal expected, actual
  end

  it "should parse a multiple option step with logic" do
    rule = <<-END
      step multiple a
        option yes ->
          if { logic } -> b
          otherwise -> c
        option no -> d
    END

    actual = Sibyl.parse(rule)
    expected = [
      [:step, "multiple", "a", [
        [:option, :branch, "yes", [
          [:if, "logic", "b"],
          [:otherwise, "c"]]],
        [:option, :simple, "no", "d"]]]]

    assert_equal expected, actual
  end

  it "should parse a step with a simple direct transition" do
    rule =<<-END
      step salary a
        go -> b
    END

    actual = Sibyl.parse(rule)
    expected = [
      [:step, "salary", "a", [
        [:go, :simple, "b"]]]]

    assert_equal expected, actual
  end

  it "should parse a step with a direct transition with logic" do
    rule =<<-END
      step salary a
        go ->
          if { logic } -> b
          otherwise -> c
    END

    actual = Sibyl.parse(rule)
    expected = [
      [:step, "salary", "a", [
        [:go, :branch, [
          [:if, "logic", "b"],
          [:otherwise, "c"]]]]]]

    assert_equal expected, actual
  end

end
