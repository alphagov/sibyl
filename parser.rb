require "sibyl"
require 'pp'

s = File.read(ARGV.first)
pp Sibyl.parse(s)
