require "common"
require "sibyl/graph"

describe "Examples" do
  Dir[File.expand_path("../../examples/*.rule", __FILE__)].each do |path|
    it "should parse example file #{File.basename(path)}" do
      graph = Sibyl::Graph.new(File.read(path))
      graph.validate!
    end
  end
end
