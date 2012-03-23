module Sibyl
  module Nodes
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
        context.input = InputHandler.deserialize(type, input)
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
  end
end
