module Steps
  module Case
    class CodefendantsController < Steps::CaseStepController
      before_action :redirect_cifc

      def edit
        @form_object = CodefendantsForm.new(
          crime_application: current_crime_application
        )
      end

      def update
        update_and_advance(
          CodefendantsForm, as: step_name, flash: flash_msg
        )
      end

      private

      def step_name
        if params.key?('add_codefendant')
          :add_codefendant
        elsif params.to_s.include?('"_destroy" => "1"')
          :delete_codefendant
        else
          :codefendants_finished
        end
      end

      def flash_msg
        { success: t('.edit.deleted_flash') } if step_name.eql?(:delete_codefendant)
      end

      def additional_permitted_params
        [{ codefendants_attributes: Steps::Case::CodefendantFieldsetForm.attribute_names }]
      end
    end
  end
end
