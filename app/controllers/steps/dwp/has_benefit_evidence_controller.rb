module Steps
  module DWP
    class HasBenefitEvidenceController < Steps::DWPStepController
      def edit
        @form_object = HasBenefitEvidenceForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(HasBenefitEvidenceForm, as: :has_benefit_evidence)
      end
    end
  end
end
