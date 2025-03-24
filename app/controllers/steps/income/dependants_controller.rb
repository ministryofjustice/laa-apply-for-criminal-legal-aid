module Steps
  module Income
    class DependantsController < Steps::IncomeStepController
      def edit
        @form_object = DependantsForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(DependantsForm, as: step_name, flash: flash_msg)
      end

      def step_name
        if params.key?('add_dependant')
          :add_dependant
        elsif params.to_s.include?('"_destroy" => "1"')
          :delete_dependant
        else
          :dependants_finished
        end
      end

      def flash_msg
        { success: t('.edit.deleted_flash') } if step_name.eql?(:delete_dependant)
      end

      def additional_permitted_params
        [dependants_attributes: Steps::Income::DependantFieldsetForm.attribute_names]
      end
    end
  end
end
