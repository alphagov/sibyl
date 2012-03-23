require "sibyl/errors"
require "sibyl/input"

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

        def def_true(*names)
          def_boolean true, *names
        end

        def def_false(*names)
          def_boolean false, *names
        end

      private
        def def_boolean(value, *names)
          names.each do |name|
            class_eval <<-END
              def #{name}?
                #{value ? "true" : "false"}
              end
            END
          end
        end
      end

      def_false :metadata, :option, :statement, :step, :sink, :branch
    end

    module Evaluable
      def evaluate(context)
        context.instance_eval(expression)
      end
    end
  end
end

Dir[File.expand_path("../nodes/*.rb", __FILE__)].each do |path|
  require "sibyl/nodes/#{File.basename(path, ".rb")}"
end
