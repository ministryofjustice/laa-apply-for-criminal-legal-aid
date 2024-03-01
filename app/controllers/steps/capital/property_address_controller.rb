module Steps
  module Capital
    class PropertyAddressController < Steps::CapitalStepController
      def edit
        @form_object = form_name.build(
          property_record, crime_application: current_crime_application
        )
      end

      def update
        update_and_advance(
          form_name, record: property_record, as: advance_as
        )
      end

      private

      # :nocov:
      def form_name
        raise 'implement this action in subclasses'
      end

      def advance_as
        raise 'implement in controllers using this concern'
      end
      # :nocov:

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
