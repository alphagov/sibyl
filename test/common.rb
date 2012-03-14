require "minitest/spec"
require "minitest/autorun"
lib = File.expand_path("../../lib", __FILE__)
$:.unshift(lib) unless $:.include?(lib)
