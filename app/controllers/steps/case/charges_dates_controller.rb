module Steps
  module Case
    class ChargesDatesController < Steps::CaseStepController
      before_action :redirect_cifc

      def edit
        @form_object = ChargesDatesForm.build(
          charge_record, crime_application: current_crime_application
        )
      end

      def update
        update_and_advance(ChargesDatesForm, record: charge_record, as: step_name)
      end

      private

      def charge_record
        @charge_record ||= case_charges.find(params[:charge_id])
      end

      def case_charges
        @case_charges ||= current_crime_application.case.charges
      end

      def additional_permitted_params
        [offence_dates_attributes: Steps::Case::OffenceDateFieldsetForm.attribute_names]
      end

      def step_name
        if params.key?('add_offence_date')
          :add_offence_date
        elsif params.to_s.include?('"_destroy" => "1"')
          :delete_offence_date
        else
          :charges_dates
        end
      end
    end
  end
end
