require "sibyl/graph"

source = File.read(ARGV.first)
graph = Sibyl::Graph.new(source)
begin
  graph.validate!
rescue Sibyl::RuleError => e
  $stderr.puts e
  exit 1
end
