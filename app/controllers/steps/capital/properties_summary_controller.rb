module Steps
  module Capital
    class PropertiesSummaryController < Steps::CapitalStepController
      before_action :require_property

      def edit
        @form_object = PropertiesSummaryForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(PropertiesSummaryForm, as: :properties_summary)
      end

      private

      def additional_permitted_params
        [:add_property]
      end

      def require_property
        return true if current_crime_application.properties.present?

        redirect_to edit_steps_capital_property_type_path(current_crime_application)
      end
    end
  end
end
