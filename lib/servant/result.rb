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
  end
end
