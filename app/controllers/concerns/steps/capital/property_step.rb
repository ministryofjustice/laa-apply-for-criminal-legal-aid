module Steps
  module Capital
    module PropertyStep
      extend ActiveSupport::Concern

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

      def property_record
        @property_record ||= current_crime_application.properties.find(params[:property_id])
      rescue ActiveRecord::RecordNotFound
        raise Errors::PropertyNotFound
      end
    end
  end
end
