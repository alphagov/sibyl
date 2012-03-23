require "sibyl/errors"
require "sibyl/parser"
require "sibyl/transform/ruby"
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

    def validate!
      validate_has_steps!
      @steps.each do |step|
        step.validate!
      end
      validate_no_unreachable_steps!
      validate_no_unresolved_targets!
      validate_no_cycles!
    rescue InvalidNode => e
      raise InvalidGraph.new(e)
    end

    def at(inputs)
      step = @first_step
      context = OpenStruct.new
      inputs.each do |input|
        result = step.compute(input, context)
        step = @steps_by_name[result]
      end
      step
    end

    def l10n_keys
      @steps.inject([]) { |keys, step|
        keys + step.l10n_keys
      }
    end

  private
    def validate_has_steps!
      if @steps.empty?
        raise InvalidGraph, "no steps"
      end
    end

    def validate_no_unreachable_steps!
      unreachable = step_names - target_names - [first_step_name]
      if unreachable.any?
        raise InvalidGraph, "unreachable step(s): #{unreachable.join("; ")}"
      end
    end

    def validate_no_unresolved_targets!
      unresolved = target_names - step_names
      if unresolved.any?
        raise InvalidGraph, "unresolved step(s): #{unresolved.join("; ")}"
      end
    end

    def validate_no_cycles!
      tsort
    rescue TSort::Cyclic
      raise InvalidGraph, "graph is cyclic"
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
      transform = Sibyl::Transform::Ruby.new
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

