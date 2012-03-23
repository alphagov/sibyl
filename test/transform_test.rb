require "common"
require "sibyl/parser"
require "sibyl/transform/ruby"

describe "Ruby Transform" do
  def ruby(source)
    parser = Sibyl::Parser.new
    transform = Sibyl::Transform::Ruby.new
    transform.apply(parser.parse(source)).first
  end

  it "should translate a metadata line" do
    md = ruby(%{
      metadata need 1660
    })

    assert_equal "need", md.key
    assert_equal 1660, md.value
  end
end
