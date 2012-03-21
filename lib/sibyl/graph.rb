require "sibyl/parser"
require "sibyl/ruby_transform"

module Sibyl
  class Graph
    attr_reader :metadata

    def initialize(source)
      elements = parse(source)
      @metadata = extract_metadata(elements)
      @steps = extract_steps(elements)
    end

    def valid?
      @steps.any? &&
      !has_unreachable_steps? &&
      !has_unresolved_targets?
    end

  private
    def has_unreachable_steps?
      (step_names - target_names - [@steps.first.name]).any?
    end

    def has_unresolved_targets?
      (target_names - step_names).any?
    end

    def step_names
      @steps.map(&:name)
    end

    def target_names
      @steps.map(&:exits).flatten.uniq
    end

    def sink_names
      @steps.select(&:sink?).map(&:name)
    end

    def parse(source)
      parser = Sibyl::Parser.new
      transform = Sibyl::RubyTransform.new
      transform.apply(parser.parse(source))
    end

    def extract_metadata(elements)
      Hash[elements.select(&:metadata?).map { |m| [m.key.to_sym, m.value] }]
    end

    def extract_steps(elements)
      elements.select(&:step?)
    end
  end
end

