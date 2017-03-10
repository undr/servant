module Servant
  class Context
    include ::ActiveModel::Validations

    class_attribute :_argument_names, instance_writer: false
    self._argument_names = []

    class << self
      def name
        'Context'
      end
    end

    attr_reader :arguments

    def initialize(arguments = {})
      @arguments = arguments
      @processed = {}
      valid?
    end

    def to_hash
      _argument_names.inject({}) do |result, name|
        result.merge(name => send(name))
      end
    end

    def errors
      @errors ||= Errors.new(self)
    end

    protected

    def preprocess(name, value, preprocessor)
      if preprocessor && preprocessor.respond_to?(:call)
        @processed[name] = preprocessor.call(value)
      else
        value
      end
    end
  end
end
