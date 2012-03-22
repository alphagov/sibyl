require "sibyl/errors"

module Sibyl
  module Nodes
    class Node
      class << self
        def construct_with(*fields)
          class_eval <<-END
            def initialize(#{fields.map(&:to_s).join(", ")})
              #{fields.map { |f| "self.%s = %s" % [f, f] }.join("\n") }
            end
          END

          attr_accessor *fields
        end

        def def_boolean(value, *names)
          names.each do |name|
            class_eval <<-END
              def #{name}?
                #{value ? "true" : "false"}
              end
            END
          end
        end

        def def_true(*names)
          def_boolean true, *names
        end

        def def_false(*names)
          def_boolean false, *names
        end
      end

      def_false :metadata, :option, :statement, :step, :sink, :branch
    end

    module Evaluable
      def evaluate(context)
        context.instance_eval(expression)
      end
    end

    class Metadata < Node
      construct_with :key, :value
      def_true :metadata
    end

    class Step < Node
      construct_with :type, :name, :body
      def_true :step

      def branches
        body.select(&:branch?)
      end

      def options
        body.select(&:option?)
      end

      def statements
        body.select(&:statement?)
      end

      def inputs
        body.select(&:option?).map(&:text)
      end

      def exits
        branches.map(&:branches).flatten.map(&:target).uniq
      end

      def compute(input, context)
        context.input = input
        statements.each do |s|
          s.execute(context)
        end
        branches.each do |o|
          result = o.compute(context)
          return result if result
        end
        raise InvalidInput
      end

      def l10n_keys
        prefix = keyify(name)
        standard = ["#{prefix}.title"]
        standard + options.map { |option| "#{prefix}.options.#{option.text}" }
      end

      def validate!
        if type.to_s == "multiple"
          raise InvalidNode, "multiple step '#{name}' has no options" if options.none?
          raise InvalidNode, "multiple step '#{name}' has non-option branches" if (branches - options).any?
        else
          raise InvalidNode, "non-multiple step '#{name}' has options" if options.any?
          raise InvalidNode, "step '#{name}' has no outputs" if branches.none?
        end
      end

    private
      def keyify(s)
        s.downcase.gsub(/^\W+|\W+$/, "").gsub(/\W+/, "_")
      end
    end

    class Outcome < Step
      construct_with :name
      def_true :sink

      def exits
        []
      end

      def body
        []
      end

      def validate!
      end
    end

    class Jump < Node
      construct_with :target

      def compute(*)
        target
      end
    end

    class ConditionalJump < Jump
      include Evaluable
      construct_with :expression, :target

      def compute(context)
        if evaluate(context)
          target
        else
          nil
        end
      end
    end

    class Brancher < Node
      construct_with :branches
      def_true :branch

      def compute(context)
        branches.each do |b|
          result = b.compute(context)
          return result if result
        end
        nil
      end
    end

    class OptionBrancher < Brancher
      construct_with :text, :branches
      def_true :option

      def compute(context)
        if context.input == text
          super(context)
        else
          nil
        end
      end
    end

    class AbstractStatement < Node
      include Evaluable
      def_true :statement
    end

    class Set < AbstractStatement
      construct_with :key, :expression

      def execute(context)
        context.__send__ "#{key}=", evaluate(context)
      end
    end

    class Reject < AbstractStatement
      construct_with :expression

      def execute(context)
        raise PreconditionFailed if evaluate(context)
      end
    end
  end
end
