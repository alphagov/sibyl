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
      end

      def metadata?
        false
      end

      def option?
        false
      end

      def statement?
        false
      end

      def metadata?
        false
      end
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

      def metadata?
        true
      end
    end

    class Step < Node
      construct_with :type, :name, :body

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

    class Outcome < Node
      construct_with :name
    end

    class Go < Node
      construct_with :target

      def compute(*)
        target
      end
    end

    class GoIf < Go
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

    class Always < Node
      construct_with :branches

      def compute(context)
        branches.each do |b|
          result = b.compute(context)
          return result if result
        end
        nil
      end

      def option?
        true
      end
    end

    class Option < Always
      construct_with :text, :branches

      def compute(context)
        if context.input == text
          super(context)
        else
          nil
        end
      end
    end

    class Set < Node
      include Evaluable
      construct_with :key, :expression

      def statement?
        true
      end

      def execute(context)
        context.__send__ "#{key}=", evaluate(context)
      end
    end

    class Reject < Node
      include Evaluable
      construct_with :expression

      def statement?
        true
      end

      def execute(context)
        raise ValidationError if evaluate(context)
      end
    end
  end
end
