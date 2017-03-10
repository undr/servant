module Servant
  class Base
    class AbortError < StandardError
      attr_reader :errors

      def initialize(errors)
        @errors = errors
        super()
      end
    end

    class_attribute :_context_class, instance_writer: false

    class << self
      def perform(*args)
        instance = new(*args)
        value = instance.errors.empty? ? instance.perform : nil
        Result.new(instance.errors, value)
      rescue AbortError => e
        Result.new(e.errors)
      end

      def perform!(*args)
        perform(*args).tap do |result|
          raise Error.new(result.errors.full_messages) if result.failed?
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

    def initialize(arguments)
      @context = _context_class.nil? ? Context.new(arguments) : _context_class.new(arguments)
      @errors  = @context.errors
    end

    private

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
      raise AbortError.new(@errors)
    end

    def halt_with!(errors)
      merge_errors!(errors)
      raise AbortError.new(@errors)
    end
  end
end
