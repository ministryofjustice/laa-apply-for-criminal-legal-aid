module Steps
  module Income
    class BusinessStartDateController < Steps::BaseStepController
      include SubjectResource
      include BusinessResource

      def edit
        @form_object = BusinessStartDateForm.build(
          business_record,
          crime_application: current_crime_application
        )
      end

      def update
        update_and_advance(
          BusinessStartDateForm,
          record: business_record,
          as: :business_start_date
        )
      end
    end
  end
end
