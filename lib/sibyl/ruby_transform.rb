require "parslet"
require "sibyl/unit"

module Sibyl
  class RubyTransform < Parslet::Transform
    include Unit

    rule(text: simple(:x)) { x.to_s }
    rule(numeric: simple(:x)) { x.to_i }
    rule(code: simple(:x)) { x.to_s.strip }
    rule(empty: simple(:x)) { [] }
    rule(type: 'if', expr: simple(:expr), target: simple(:target)) {
      ConditionalJump.new(expr, target)
    }
    rule(type: 'set', var: simple(:var), expr: simple(:expr)) {
      Set.new(var, expr)
    }
    rule(type: 'otherwise', target: simple(:target)) {
      Jump.new(target)
    }
    rule(type: 'branch', branch: subtree(:branch), from: simple(:from)) {
      OptionBrancher.new(from, branch)
    }
    rule(type: 'option', branch: subtree(:branch), from: simple(:from)) {
      OptionBrancher.new(from, branch)
    }
    rule(type: 'option', target: simple(:target), from: simple(:from)) {
      OptionBrancher.new(from, [Jump.new(target)])
    }
    rule(type: 'go', branch: subtree(:branch)) {
      Brancher.new(branch)
    }
    rule(type: 'go', target: simple(:target)) {
      Brancher.new([Jump.new(target)])
    }
    rule(type: 'reject', expr: simple(:expr)) {
      Reject.new(expr)
    }
    rule(type: 'step', subtype: simple(:subtype), name: simple(:name), body: subtree(:body)) {
      Step.new(subtype, name, body)
    }
    rule(type: 'outcome', name: simple(:name)) {
      Outcome.new(name)
    }
    rule(type: 'metadata', key: simple(:key), value: simple(:value)) {
      Metadata.new(key, value)
    }
  end
end

