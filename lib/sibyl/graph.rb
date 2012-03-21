require "sibyl/parser"
require "sibyl/ruby_transform"

module Sibyl
  class Graph
    attr_reader :metadata

    def initialize(source)
      elements = parse(source)
      @metadata = extract_metadata(elements)
    end

  private
    def parse(source)
      parser = Sibyl::Parser.new
      transform = Sibyl::RubyTransform.new
      transform.apply(parser.parse(source))
    end

    def extract_metadata(elements)
      Hash[elements.select(&:metadata?).map { |m| [m.key.to_sym, m.value] }]
    end
  end
end

