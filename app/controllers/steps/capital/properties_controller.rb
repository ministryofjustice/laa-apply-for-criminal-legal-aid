module Steps
  module Capital
    class PropertiesController < Steps::CapitalStepController
      def edit
        @form_object = PropertiesForm.build(
          property_record, crime_application: current_crime_application
        )
      end

      def update
        update_and_advance(
          PropertiesForm, record: property_record, as: :properties
        )
      end

      private

      def property_record
        @property_record ||= properties.find(params[:property_id])
      rescue ActiveRecord::RecordNotFound
        raise Errors::PropertyNotFound
      end

      def properties
        @properties ||= current_crime_application.properties
      end
    end
  end
end