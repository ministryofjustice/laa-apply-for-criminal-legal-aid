module Steps
  module Partner
    class HomeAddressController < Steps::PartnerStepController
      def edit
        @form_object = Steps::Partner::HomeAddressForm.build(
          partner_details
        )
      end

      def update
        update_and_advance(Steps::Partner::HomeAddressForm, as: :home_address)
      end
    end
  end
end
