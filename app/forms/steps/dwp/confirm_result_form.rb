module Steps
  module DWP
    class ConfirmResultForm < Steps::DWP::DWPBaseForm
      attribute :confirm_dwp_result, :value_object, source: YesNoAnswer

      validate :confirm_dwp_result_selected

      def choices
        YesNoAnswer.values
      end

      private

      def persist!
        crime_application.update(attributes)

        return true if confirm_dwp_result.no?

        update_person_attributes if confirm_dwp_result.yes?
      end

      def update_person_attributes
        return crime_application.partner.update(attributes_to_update) if partner_has_benefit?

        crime_application.applicant.update(attributes_to_update)
      end

      def attributes_to_update
        {
          'benefit_type' => BenefitType::NONE,
          'has_benefit_evidence' => nil,
          'confirm_details' => nil
        }
      end

      def confirm_dwp_result_selected
        return if YesNoAnswer.values.include?(confirm_dwp_result) # rubocop:disable Performance/InefficientHashSearch

        errors.add(:confirm_dwp_result, :blank, subject:)
      end
    end
  end
end
