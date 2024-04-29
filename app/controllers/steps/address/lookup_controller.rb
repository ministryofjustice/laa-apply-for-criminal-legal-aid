module Steps
  module Address
    class LookupController < Steps::AddressStepController
      def edit
        @form_object = LookupForm.build(
          address_record, crime_application: current_crime_application
        )
      end

      def update
        update_and_advance(
          LookupForm, record: address_record, as: :lookup
        )
      end
    end
  end
end
