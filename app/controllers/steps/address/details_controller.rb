module Steps
  module Address
    class DetailsController < Steps::AddressStepController
      def edit
        @form_object = DetailsForm.build(
          address_record, crime_application: current_crime_application
        )
      end

      def update
        update_and_advance(
          DetailsForm, record: address_record, as: :details
        )
      end
    end
  end
end
