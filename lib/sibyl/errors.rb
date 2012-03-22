module Sibyl
  RuleError = Class.new(StandardError)
  InvalidGraph = Class.new(RuleError)
  InvalidNode = Class.new(RuleError)

  UserError = Class.new(RuntimeError)
  InvalidInput = Class.new(UserError)
  PreconditionFailed = Class.new(UserError)
end
