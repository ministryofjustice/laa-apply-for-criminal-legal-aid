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
          redirect_to edit_steps_savings_summary_path,
                      success: t('.success_flash')
        else
          # If this was the last remaining record, redirect
          # to the charges page with a new blank one
          charge = savings.create!
          redirect_to edit_steps_savings_path(saving_id: charge),
                      success: t('.success_flash')
        end
      end

      def confirm_destroy
        @saving = helpers.present(saving_record)
      end

      private

      def saving_record
        @saving_record ||= savings.find(params[:saving_id])
      end

      def savings
        @savings ||= current_crime_application.savings
      end

      def additional_permitted_params
        [offence_dates_attributes: Steps::Case::OffenceDateFieldsetForm.attribute_names]
      end
    end
  end
end
