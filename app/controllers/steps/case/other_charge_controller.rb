module Steps
  module Case
    class OtherChargeController < Steps::CaseStepController
      include SubjectResource

      def edit
        @form_object = OtherChargeForm.build(
          other_charge,
          crime_application: current_crime_application,
        )
      end

      def update
        update_and_advance(OtherChargeForm, as: :other_charge, record: other_charge)
      end

      private

      def other_charge
        @other_charge ||= current_crime_application.case.send(:"#{@subject.to_param}_other_charge")
      end
    end
  end
end
