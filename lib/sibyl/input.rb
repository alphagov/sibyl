module Sibyl
  class InputHandler
    class << self
      def register(slug, handler)
        handlers[slug] = handler
      end

      def deserialize(slug, input)
        handlers[slug].call(input)
      end

    private
      def handlers
        default = lambda { |s| s }
        @handlers ||= Hash.new { |h, k| h[k] = default }
      end
    end
  end
end

Dir[File.expand_path("../input/*.rb", __FILE__)].each do |path|
  require "sibyl/input/#{File.basename(path, ".rb")}"
end
