class TestService < Servant::Base
  context do
    argument :attr1, presence: true, type: String
    argument :attr2, presence: true, type: Integer, default: -> { Time.now.to_i }
    argument :attr3, type: Hash
  end

  def perform
    error!('Some not critical error') if context.attr1 == 'error'
    halt!('Critical error') if context.attr1 == 'critical'

    'Value'
  end
end