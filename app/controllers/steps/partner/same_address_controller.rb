module Steps
  module Partner
    class SameAddressController < Steps::PartnerStepController
      def edit
        @form_object = SameAddressForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(SameAddressForm, as: :same_address)
      end
    end
  end
end
