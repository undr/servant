module Servant
  class ContextBuilder
    class TypeValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        record.errors.add attribute, "must be a type of #{options[:with]}" if wrong_type?(value, options)
      end

      private

      def wrong_type?(value, options)
        !value.nil? && !value.is_a?(options[:with])
      end
    end

    DEFAULT_NORMALIZER = -> (value) do
      case value
      when Proc
        value.call
      else
        value
      end
    end

    def initialize(&block)
      instance_eval(&block)
    end

    def argument(name, options = {})
      name = name.to_sym

      default = options.delete(:default)
      preprocessor = options.delete(:preprocess)

      klass._argument_names = klass._argument_names + [name]

      klass.send(:define_method, name) do
        return @processed[name] if @processed.has_key?(name)

        if arguments[name]
          preprocess(name, arguments[name], preprocessor)
        else
          DEFAULT_NORMALIZER.call(default)
        end
      end

      if type = options.delete(:type)
        options[:'Servant::ContextBuilder::Type'] = type
      end

      validates(name, options) if options.any?
    end

    def validates(*args)
      klass.validates(*args)
    end

    def build
      klass
    end

    private

    def klass
      @klass ||= Class.new(Context)
    end
  end
end
