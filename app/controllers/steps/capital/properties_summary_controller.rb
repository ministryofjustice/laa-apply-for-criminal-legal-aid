module Steps
  module Capital
    class PropertiesSummaryController < Steps::CapitalStepController
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
    end
  end
end
