module Steps
  module Case
    class CodefendantsController < Steps::CaseStepController
      def edit
        @form_object = CodefendantsForm.new(
          crime_application: current_crime_application
        )
      end

      def update
        update_and_advance(CodefendantsForm, as: step_name)
      end

      private

      def step_name
        params.key?('add_codefendant') ? :add_codefendant : :codefendants_finished
      end

      def additional_permitted_params
        [codefendants_attributes: Steps::Case::CodefendantFieldsetForm.attribute_names]
      end
    end
  end
end
