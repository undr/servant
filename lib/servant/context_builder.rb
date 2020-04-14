module Servant
  class ContextBuilder
    class TypeValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        types = get_types(options)
        record.errors.add attribute, "must be any of these types: #{types.join(', ')}" if types.present? && wrong_type?(value, types)
      end

      private

      def wrong_type?(value, types)
        !value.nil? && types.none? { |type| value.is_a?(type) }
      end

      def get_types(options)
        case
        when options[:with].present?
          [options[:with]]
        when options[:in].present?
          options[:in]
        else
          []
        end
      end
    end

    AVAILABLE_OPTION_KEYS = [:type, :coerce, :default].freeze
    DEFAULT_NORMALIZER = -> (value) do
      case value
      when Proc
        value.call
      else
        value
      end
    end

    def initialize(&block)
      instance_eval(&block) if block_given?
    end

    def argument(name, options = {})
      name = name.to_sym
      default = options[:default]
      coercion = options[:coerce]

      klass._argument_names = klass._argument_names + [name]

      klass.send(:define_method, name) do
        return @coerced[name] if @coerced.has_key?(name)

        if arguments[name]
          coerce(name, arguments[name], coercion)
        else
          DEFAULT_NORMALIZER.call(default)
        end
      end

      validate_options = validate_options(options)
      validates(name, validate_options) if validate_options.any?
    end

    def validates(*args)
      klass.validates(*args)
    end

    def build
      klass
    end

    private

    def validate_options(options)
      options.dup.tap do |opts|
        if type = opts[:type]
          opts[:'Servant::ContextBuilder::Type'] = type
        end

        AVAILABLE_OPTION_KEYS.each { |key| opts.delete(key) }
      end
    end

    def klass
      @klass ||= Class.new(Context)
    end
  end
end
