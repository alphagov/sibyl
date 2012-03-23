module Sibyl
  module Nodes
    class Set < Node
      include Evaluable
      def_true :statement
      construct_with :key, :expression

      def execute(context)
        context.__send__ "#{key}=", evaluate(context)
      end
    end

    class Reject < Node
      include Evaluable
      def_true :statement
      construct_with :expression

      def execute(context)
        raise PreconditionFailed if evaluate(context)
      end
    end
  end
end
