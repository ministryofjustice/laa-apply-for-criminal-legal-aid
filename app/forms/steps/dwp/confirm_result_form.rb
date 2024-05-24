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

        return true if confirm_dwp_result.no?

        crime_application.applicant.update(attributes_to_update) if confirm_dwp_result.yes?
      end

      def attributes_to_update
        {
          'benefit_type' => BenefitType::NONE,
          'has_benefit_evidence' => nil,
          'confirm_details' => nil
        }
      end
    end
  end
end
