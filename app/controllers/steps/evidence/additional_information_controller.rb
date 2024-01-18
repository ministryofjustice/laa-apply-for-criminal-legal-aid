module Steps
  module Evidence
    class AdditionalInformationController < Steps::EvidenceStepController
      def edit
        @form_object = AdditionalInformationForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(AdditionalInformationForm, as: :additional_information)
      end

      private

      def additional_permitted_params
        [:add_additional_information]
      end
    end
  end
end
