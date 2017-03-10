module Servant
  class Error < StandardError
    attr_reader :errors

    def initialize(errors, message = "")
      super(message.presence || errors)
      @errors = errors
    end
  end
end
