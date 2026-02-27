module Steps
  module Income
    module Client
      class DeductionsForm < Steps::BaseFormObject
        attr_accessor :employment

        attr_writer :types
        attr_reader :new_deductions

        attribute :deductions, array: true, default: [] # Used by BaseFormObject

        validates_with DeductionsValidator

        DeductionType.values.each do |type| # rubocop:disable Style/HashEachMethods
          attribute type.to_s, :string

          # Used by govuk form component to retrieve values to populate the fields_for
          # for each type (on page load). Trigger validation on load.
          define_method :"#{type}" do
            deduction_fieldset_form_name.build(find_or_create_deduction(type), crime_application:).tap do |record|
              self.employment = record.employment
              record.valid? if types.include?(type.to_s)
            end
          end

          # Used to convert attributes for a given type into a corresponding fieldset
          # (on form submit). 'type' is the checkbox value
          define_method :"#{type}=" do |attrs|
            @new_deductions ||= {}
            record = deduction_fieldset_form_name.build(
              Deduction.new(employment: employment, deduction_type: type.to_s, **attrs),
              crime_application:
            )
            self.employment = record.employment

            # Save on demand, not at end to allow partial updates of the form
            if types.include?(type.to_s)
              record.save
            else
              record.delete
            end

            # @new_deductions used as a temporary store to allow error messages to
            # be displayed for invalid models
            @new_deductions[type.value.to_s] = record
          end
        end

        def ordered_deductions
          # sort alphabetically
          DeductionType.values.map(&:to_s).sort
        end

        def types
          return @types if @types
          return ['none'] if employment.has_no_deductions == 'yes'

          employment.deductions.pluck(:deduction_type)
        end

        def has_no_deductions
          'yes' if types.include?('none')
        end

        private

        def deduction_fieldset_form_name
          DeductionFieldsetForm
        end

        # :nocov:
        # Precedence: submitted values, stored values, empty Deduction
        def find_or_create_deduction(type) # rubocop:disable Metrics/AbcSize
          if types.include?(type.to_s) && @new_deductions&.key?(type.value.to_s)
            attrs = @new_deductions[type.value.to_s].attributes
            return Deduction.new(employment: employment, deduction_type: type.to_s, **attrs)
          end

          deduction = employment.deductions.find_by(deduction_type: type.value.to_s)
          return deduction if deduction

          Deduction.new(employment: employment, deduction_type: type.to_s)
        end
        # :nocov:

        # Individual deductions_fieldset_forms are in charge of saving themselves
        def persist!
          employment.update(has_no_deductions:)
        end
      end
    end
  end
end
