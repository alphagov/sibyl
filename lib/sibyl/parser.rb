require "parslet"

module Sibyl
  class Parser < Parslet::Parser
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
    rule(:braced) {
      ((str('{') >> braced >> str('}')) | match('[^}]')).repeat
    }
    rule(:code) {
      str('{') >> braced.as(:code) >> str('}') >> s?
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
    rule(:empty) {
      s?.as(:empty)
    }
    rule(:document) {
      s? >> (step | outcome | metadata).repeat(1) | empty
    }
    root(:document)
  end
end
