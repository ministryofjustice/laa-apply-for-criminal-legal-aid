module Steps
  module Capital
    class PropertyAddressController < Steps::CapitalStepController
      def edit
        @form_object = PropertyAddressForm.build(
          property_record, crime_application: current_crime_application
        )
      end

      def update
        update_and_advance(PropertyAddressForm, record: property_record, as: :property_address)
      end

      private

      def property_record
        @property_record ||= current_crime_application.properties.find(params[:property_id])
      rescue ActiveRecord::RecordNotFound
        raise Errors::PropertyNotFound
      end

      def additional_permitted_params
        [address: [:address_line_one, :address_line_two, :city, :country, :postcode]]
      end
    end
  end
end
