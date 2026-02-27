module Steps
  module Income
    class PartnerEmploymentStatusController < Steps::IncomeStepController
      def edit
        @form_object = PartnerEmploymentStatusForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(PartnerEmploymentStatusForm, as: :partner_employment_status)
      end

      private

      def additional_permitted_params
        [{ partner_employment_status: [] }]
      end
    end
  end
end
