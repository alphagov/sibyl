require "sibyl/errors"

module Sibyl
  module Unit
    class Element
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

      def_false :metadata, :option, :statement, :step, :sink
    end

    class Declaration < Element
    end

    class Node < Element
    end

    module Evaluable
      def evaluate(context)
        context.instance_eval(expression)
      end
    end

    class Metadata < Declaration
      construct_with :key, :value
      def_true :metadata
    end

    class Step < Node
      construct_with :type, :name, :body
      def_true :step

      def options
        body.select(&:option?)
      end

      def statements
        body.select(&:statement?)
      end

      def inputs
        options.map(&:text)
      end

      def exits
        body.select(&:option?).map(&:branches).flatten.map(&:target).uniq
      end

      def compute(input, context)
        context.input = input
        statements.each do |s|
          s.execute(context)
        end
        options.each do |o|
          result = o.compute(context)
          return result if result
        end
        raise ValidationError
      end
    end

    class Outcome < Step
      construct_with :name
      def_true :sink

      def exits
        []
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
      def_true :option

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
        raise ValidationError if evaluate(context)
      end
    end
  end
end
