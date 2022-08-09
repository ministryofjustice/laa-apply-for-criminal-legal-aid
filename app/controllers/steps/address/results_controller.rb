module Steps
  module Address
    class ResultsController < Steps::AddressStepController
      def edit
        @form_object = ResultsForm.build(
          address_record, crime_application: current_crime_application
        )
      end

      def update
        update_and_advance(
          ResultsForm, record: address_record, as: :results
        )
      end
    end
  end
end
