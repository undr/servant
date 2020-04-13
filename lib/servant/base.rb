module Servant
  class Base
    class_attribute :_context_class, instance_writer: false

    class << self
      def perform(*args)
        new(*args).send(:fetch_result)
      end

      def perform!(*args)
        perform(*args).tap do |result|
          raise Exceptions::ExecutionFailed.new(result.errors) if result.failed?
        end
      end

      def call(*args)
        result = perform!(*args)
        result.value
      end

      def context(&block)
        self._context_class = ContextBuilder.new(&block).build
      end
    end

    attr_reader :errors, :context
    private_class_method :new

    def initialize(arguments)
      @context = _context_class.nil? ? Context.new(arguments) : _context_class.new(arguments)
      @errors  = @context.errors
    end

    def perform
    end

    def merge_errors!(*error_objects)
      error_objects.each do |error_object|
        error_object.each do |code, message|
          error!(message, code)
        end
      end
    end

    def error!(message, code = :base)
      @errors.add(code, message)
    end

    def halt!(message, code = :base)
      error!(message, code)
      raise Exceptions::ExecutionAborted.new(errors)
    end

    def halt_with!(other_errors)
      merge_errors!(other_errors)
      raise Exceptions::ExecutionAborted.new(errors)
    end

    private

    def fetch_result
      value = errors.empty? ? perform : nil
      Result.new(errors, value)
    rescue Exceptions::ExecutionAborted => e
      Result.new(e.errors)
    end
  end
end
