module Steps
  module FieldValidation
    extend ActiveSupport::Concern

    # rubocop:disable Metrics/MethodLength
    def numericality(attribute, options = {})
      errors = []
      value =
        begin
          Kernel.Float(send(attribute))
        rescue ArgumentError, TypeError
          nil
        end

      return errors << :not_a_number if value.nil?

      options.each do |option, arg|
        result = validate_numericality_option(option, arg, value)
        errors << result if result.present?
      end
      errors
    end
    # rubocop:enable Metrics/MethodLength

    private

    def validate_numericality_option(option, arg, value)
      case option
      when :greater_than
        :greater_than if value <= arg
      end
    end
  end
end
