module Steps
  module DWP
    class ConfirmResultForm < Steps::BaseFormObject
      attribute :confirm_result, :value_object, source: YesNoAnswer

      validates_inclusion_of :confirm_result, in: :choices

      def choices
        YesNoAnswer.values
      end

      private

      def persist!
        return reset_benfit_type! if confirm_result.yes?

        true
      end

      def reset_benfit_type!
        return true if crime_application.applicant.benefit_type.blank?

        crime_application.applicant.update(benefit_type: nil)
      end
    end
  end
end
