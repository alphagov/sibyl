require "sibyl/parser"
require "sibyl/ruby_transform"
require "tsort"

module Sibyl
  class Graph
    include TSort

    attr_reader :metadata

    def initialize(source)
      elements = parse(source)
      @metadata = extract_metadata(elements)
      @steps = extract_steps(elements)
      @first_step = @steps.first
      @steps_by_name = Hash[@steps.map { |s| [s.name, s] }]
    end

    def valid?
      @steps.any? &&
      !has_unreachable_steps? &&
      !has_unresolved_targets? &&
      !has_cycles?
    end

    def l10n_keys
      @steps.inject([]) { |keys, step|
        keys + step.l10n_keys
      }
    end

  private
    def has_unreachable_steps?
      (step_names - target_names - [first_step_name]).any?
    end

    def has_unresolved_targets?
      (target_names - step_names).any?
    end

    def has_cycles?
      tsort
      false
    rescue TSort::Cyclic
      true
    end

    def first_step_name
      @first_step.name
    end

    def step_names
      @steps_by_name.keys
    end

    def tsort_each_node(&blk)
      step_names.each(&blk)
    end

    def tsort_each_child(node, &blk)
      @steps_by_name[node].exits.each(&blk)
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

