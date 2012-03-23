require "parslet"

module Sibyl
  module Transform
    class Sexp < Parslet::Transform
      rule(text: simple(:x)) { x.to_s }
      rule(numeric: simple(:x)) { x.to_i }
      rule(code: simple(:x)) { x.to_s.strip }
      rule(empty: simple(:x)) { [] }
      rule(type: 'if', expr: simple(:expr), target: simple(:target)) {
        [:if, expr, target]
      }
      rule(type: 'set', var: simple(:var), expr: simple(:expr)) {
        [:set, var, expr]
      }
      rule(type: 'otherwise', target: simple(:target)) {
        [:otherwise, target]
      }
      rule(type: 'option', branch: subtree(:branch), from: simple(:from)) {
        [:option, :branch, from, branch]
      }
      rule(type: 'option', target: simple(:target), from: simple(:from)) {
        [:option, :simple, from, target]
      }
      rule(type: 'go', branch: subtree(:branch)) {
        [:go, :branch, branch]
      }
      rule(type: 'go', target: simple(:target)) {
        [:go, :simple, target]
      }
      rule(type: 'reject', expr: simple(:expr)) {
        [:reject, expr.to_s.strip]
      }
      rule(type: 'step', subtype: simple(:subtype), name: simple(:name), body: subtree(:body)) {
        [:step, subtype, name, body]
      }
      rule(type: 'outcome', name: simple(:name)) {
        [:outcome, name]
      }
      rule(type: 'metadata', key: simple(:key), value: simple(:value)) {
        [:metadata, key, value]
      }
    end
  end
end
