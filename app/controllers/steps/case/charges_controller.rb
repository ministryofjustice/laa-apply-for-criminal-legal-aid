module Steps
  module Case
    class ChargesController < Steps::CaseStepController
      before_action :redirect_cifc

      def edit
        @form_object = ChargesForm.build(
          charge_record, crime_application: current_crime_application
        )
      end

      def update
        update_and_advance(
          ChargesForm, record: charge_record, as: step_name, flash: flash_msg
        )
      end

      def destroy
        charge_record.destroy

        if case_charges.reload.any?
          redirect_to edit_steps_case_charges_summary_path,
                      success: t('.success_flash')
        else
          # If this was the last remaining record, redirect
          # to the charges page with a new blank one
          charge = case_charges.create!
          redirect_to edit_steps_case_charges_path(charge_id: charge),
                      success: t('.success_flash')
        end
      end

      def confirm_destroy
        @charge = helpers.present(charge_record)
      end

      private

      def step_name
        if params.key?('add_offence_date')
          :add_offence_date
        elsif params.to_s.include?('"_destroy" => "1"')
          :delete_offence_date
        else
          :charges
        end
      end

      def flash_msg
        { success: t('.edit.deleted_flash') } if step_name.eql?(:delete_offence_date)
      end

      def charge_record
        @charge_record ||= case_charges.find(params[:charge_id])
      end

      def case_charges
        @case_charges ||= current_crime_application.case.charges
      end

      def additional_permitted_params
        [offence_dates_attributes: Steps::Case::OffenceDateFieldsetForm.attribute_names]
      end
    end
  end
end
