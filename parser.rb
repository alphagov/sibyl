require "parslet"

class P < Parslet::Parser
  rule(:s) { match('\s').repeat(1) }
  rule(:s?) { s.maybe >> (str('--') >> match('[^\n]').repeat >> s.maybe).repeat | s.maybe }
  rule(:word) {
    (match('[a-zA-Z]') >> match('[a-zA-Z0-9\-_]').repeat).as(:text) >> s?
  }
  rule(:qstring) {
    str('"') >> (match('[^"]') | str('\\"')).repeat.as(:text) >> str('"') >> s?
  }
  rule(:string) { word | qstring }
  rule(:value) { number | string }
  rule(:number) { match('[0-9]').repeat(1).as(:numeric) >> s? }
  rule(:arrow) { str('->') >> s? }
  rule(:target) {
    string.as(:target)
  }
  rule(:branch) {
    (branch_if.repeat(1) >> branch_otherwise).as(:branch)
  }
  rule(:branch_if) {
    str('if').as(:type) >> s? >> code.as(:expr) >> arrow >> target
  }
  rule(:branch_otherwise) {
    str('otherwise').as(:type) >> s? >> arrow >> target
  }
  rule(:code) {
    str('{') >> match('[^}]').repeat.as(:code) >> str('}') >> s?
  }
  rule(:stepdef) {
    str('step').as(:type) >> s? >> string.as(:subtype) >> string.as(:name)
  }
  rule(:option) {
    str('option').as(:type) >> s? >> string.as(:from) >> arrow >> (branch | target)
  }
  rule(:reject) {
    str('reject').as(:type) >> s? >> code.as(:expr)
  }
  rule(:set) {
    str('set').as(:type) >> s? >> string.as(:var) >> code.as(:expr)
  }
  rule(:go) {
    str('go').as(:type) >> s? >> arrow >> (branch | target)
  }
  rule(:step) {
    stepdef >> (reject | option | set | go).repeat.as(:body)
  }
  rule(:outcome) {
    str('outcome').as(:type) >> s? >> string.as(:name)
  }
  rule(:metadata) {
    str('metadata').as(:type) >> s? >> string.as(:key) >> value.as(:value)
  }
  rule(:document) {
    (step | outcome | metadata).repeat
  }
  root(:document)
end

class T < Parslet::Transform
  rule(text: simple(:x)) { x.to_s }
  rule(numeric: simple(:x)) { x.to_i }
  rule(code: simple(:x)) { x.to_s.strip }
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

s = File.read(ARGV.first)

require 'pp'
parser = P.new
p = parser.parse(s)
pp T.new.apply(p)
