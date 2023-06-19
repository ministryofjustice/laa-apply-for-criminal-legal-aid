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
          LookupForm, record: address_record, as: step_name
        )
      end

      private

      def step_name
        params.key?(:clear_address) ? :clear_address : :lookup
      end
    end
  end
end
