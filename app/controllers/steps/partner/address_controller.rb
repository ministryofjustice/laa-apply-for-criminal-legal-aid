module Steps
  module Partner
    class AddressController < Steps::PartnerStepController
      def edit
        @form_object = AddressForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(AddressForm, as: :address)
      end
    end
  end
end
