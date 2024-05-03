module Steps
  module DWP
    class ConfirmResultForm < Steps::BaseFormObject
      attribute :confirm_dwp_result, :value_object, source: YesNoAnswer

      validates_inclusion_of :confirm_dwp_result, in: :choices

      def choices
        YesNoAnswer.values
      end

      private

      def persist!
        crime_application.update(attributes)

        # crime_application.applicant.update(benefit_type: BenefitType::NONE) if confirm_dwp_result.yes?
      end
    end
  end
end
