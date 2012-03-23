module Sibyl
  module Nodes
    class Metadata < Node
      construct_with :key, :value
      def_true :metadata
    end
  end
end

