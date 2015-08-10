require 'xspec'

module AggregateFailures
  include XSpec::Evaluator::Simple

  def call(uow)
    @failures = []

    result = begin
      super
      []
    rescue => e
      [[e.message, e.backtrace]]
    end

    (@failures + result).map do |data|
      XSpec::Failure.new(uow, *data)
    end
  end

  def _raise(message)
    @failures << [message, caller]
  end
end

extend XSpec.dsl(
  evaluator: XSpec::Evaluator.stack {
    include AggregateFailures
  }
)

require 'card_game'

CG = CardGame
