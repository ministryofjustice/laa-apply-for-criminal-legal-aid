module Steps
  module Partner
    class DetailsController < Steps::PartnerStepController
      def edit
        @form_object = DetailsForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(DetailsForm, as: :details)
      end
    end
  end
end
