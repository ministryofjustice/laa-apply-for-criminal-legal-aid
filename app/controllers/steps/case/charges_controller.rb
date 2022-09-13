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
          ChargesForm, record: charge_record, as: :charges
        )
      end

      private

      def charge_record
        @charge_record ||= case_charges.find(params[:charge_id])
      end

      def case_charges
        @case_charges ||= current_crime_application.case.charges
      end
    end
  end
end
