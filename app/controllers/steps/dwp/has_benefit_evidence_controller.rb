module Steps
  module DWP
    class HasBenefitEvidenceController < Steps::DWPStepController
      def edit
        @form_object = form.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(form, as: :has_benefit_evidence)
      end

      def form
        benefit_check_on_partner? ? HasBenefitEvidencePartnerForm : HasBenefitEvidenceForm
      end
    end
  end
end
