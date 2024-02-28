module Steps
  module Capital
    class SavingsController < Steps::CapitalStepController
      def edit
        @form_object = SavingsForm.build(
          saving_record, crime_application: current_crime_application
        )
      end

      def update
        update_and_advance(
          SavingsForm, record: saving_record, as: :savings
        )
      end

      def destroy
        saving_record.destroy

        if savings.reload.any?
          redirect_to edit_steps_capital_savings_summary_path, success: t('.success_flash')
        else
          # If this was the last remaining record, redirect to the saving type page
          redirect_to edit_steps_capital_saving_type_path, success: t('.success_flash')
        end
      end

      def confirm_destroy
        @saving = saving_record
      end

      private

      def saving_record
        @saving_record ||= savings.find(params[:saving_id])
      rescue ActiveRecord::RecordNotFound
        raise Errors::SavingNotFound
      end

      def savings
        @savings ||= current_crime_application.savings
      end

      def additional_permitted_params
        [:confirm_in_applicants_name]
      end
    end
  end
end
