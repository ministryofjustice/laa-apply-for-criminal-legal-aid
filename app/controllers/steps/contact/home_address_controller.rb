module Steps
  module Contact
    class HomeAddressController < Steps::ContactStepController
      def edit
        @form_object = HomeAddressForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(HomeAddressForm, as: :home_address)
      end
    end
  end
end
