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
  end
end
