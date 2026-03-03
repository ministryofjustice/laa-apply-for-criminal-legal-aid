require 'laa_crime_schemas'

module Steps
  module Income
    class IncomeBenefitsForm < Steps::BaseFormObject
      include Steps::HasOneAssociation

      has_one_association :income

      PAYMENT_TYPES_ORDER = Types::IncomeBenefitType.values

      attr_writer :types
      attr_reader :new_payments

      attribute :income_benefits, array: true, default: [] # Used by BaseFormObject

      validate { errors.add(:base, :none_selected) if @types.nil? }

      validates_with IncomeBenefitsValidator

      IncomeBenefitType.values.each do |type| # rubocop:disable Style/HashEachMethods
        attribute type.to_s, :string

        # Used by govuk form component to retrieve values to populate the fields_for
        # for each type (on page load). Trigger validation on load.
        define_method :"#{type}" do
          IncomeBenefitFieldsetForm.build(find_or_create_income_benefit(type), crime_application:).tap do |record|
            record.valid? if types.include?(type.to_s)
          end
        end

        # Used to convert attributes for a given type into a corresponding fieldset
        # (on form submit). 'type' is the checkbox value
        define_method :"#{type}=" do |attrs|
          @new_payments ||= {}
          record = IncomeBenefitFieldsetForm.build(
            IncomeBenefit.new(payment_type: type.to_s, ownership_type: OwnershipType::APPLICANT.to_s, **attrs),
            crime_application:
          )

          # Save on demand, not at end to allow partial updates of the form
          if types.include?(type.to_s)
            record.save
          else
            record.delete
          end

          # @new_payments used as a temporary store to allow error messages to
          # be displayed for invalid models
          @new_payments[type.value.to_s] = record
        end
      end

      def ordered_payment_types
        IncomeBenefitType.values.map(&:to_s) & PAYMENT_TYPES_ORDER
      end

      def types
        return @types if @types
        return ['none'] if income.has_no_income_benefits == 'yes'

        crime_application.applicant.income_benefits.pluck(:payment_type)
      end

      def has_no_income_benefits
        'yes' if types.include?('none')
      end

      private

      # Precedence: submitted values, stored values, empty IncomeBenefit
      def find_or_create_income_benefit(type) # rubocop:disable Metrics/AbcSize
        if types.include?(type.to_s) && @new_payments&.key?(type.value.to_s)
          attrs = @new_payments[type.value.to_s].attributes
          return IncomeBenefit.new(payment_type: type.to_s, ownership_type: OwnershipType::APPLICANT.to_s, **attrs)
        end

        income_benefit = crime_application.applicant.income_benefits.find_by(payment_type: type.value.to_s)
        return income_benefit if income_benefit

        IncomeBenefit.new(payment_type: type.to_s, ownership_type: OwnershipType::APPLICANT.to_s,)
      end

      # Individual income_benefits_fieldset_forms are in charge of saving themselves
      def persist!
        crime_application.income.update(has_no_income_benefits:)
      end
    end
  end
end
