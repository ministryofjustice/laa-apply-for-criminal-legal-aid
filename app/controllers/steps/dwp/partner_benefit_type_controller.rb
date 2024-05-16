module Steps
  module DWP
    class PartnerBenefitTypeController < Steps::DWPStepController
      def edit
        @form_object = PartnerBenefitTypeForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(PartnerBenefitTypeForm, as: :partner_benefit_type)
      end
    end
  end
end
