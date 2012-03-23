module Sibyl
  module Nodes
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
        context.input == text ? super(context) : nil
      end
    end
  end
end
