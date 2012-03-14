require "sibyl/parser"
require "sibyl/transform"

module Sibyl
  def self.parse(s)
    parser = Sibyl::Parser.new
    transform = Sibyl::Transform.new
    transform.apply(parser.parse(s))
  end
end
