require "sibyl/parser"
require "sibyl/sexp_transform"
require 'pp'

source = File.read(ARGV.first)
parser = Sibyl::Parser.new
sexp_transform = Sibyl::SexpTransform.new
sexp = sexp_transform.apply(parser.parse(source))
pp sexp
