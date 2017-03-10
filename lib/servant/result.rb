module Servant
  class Result
    attr_reader :errors, :value

    def initialize(errors, value = nil)
      @errors = errors.freeze
      @value  = value
    end

    def success?
      @errors.empty?
    end

    def failed?
      !success?
    end

    def raise_error_if_unsuccess!
      raise(StandardError, errors.full_messages) unless success?
    end
  end
end
