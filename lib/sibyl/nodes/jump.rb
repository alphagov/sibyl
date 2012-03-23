module Sibyl
  module Nodes
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
        evaluate(context) ? super(context) : nil
      end
    end
  end
end
