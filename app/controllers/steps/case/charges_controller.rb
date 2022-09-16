module Steps
  module Case
    class ChargesController < Steps::CaseStepController
      def edit
        @form_object = ChargesForm.build(
          charge_record, crime_application: current_crime_application
        )
      end

      def update
        update_and_advance(
          ChargesForm, record: charge_record, as: step_name
        )
      end

      private

      def step_name
        if params.key?('add_offence_date')
          :add_offence_date
        elsif params.to_s.include?('"_destroy"=>"1"')
          :delete_offence_date
        else
          :charges
        end
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
