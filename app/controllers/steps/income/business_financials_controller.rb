module Steps
  module Income
    class BusinessFinancialsController < Steps::BaseStepController
      include SubjectResource
      include BusinessResource

      def edit
        @form_object = BusinessFinancialsForm.build(
          business_record,
          crime_application: current_crime_application
        )
      end

      def update
        update_and_advance(
          BusinessFinancialsForm,
          record: business_record,
          as: :business_financials
        )
      end

      private

      def additional_permitted_params
        [
          :turnover_amount, :turnover_frequency,
          :profit_amount, :profit_frequency,
          :drawings_amount, :drawings_frequency,
        ]
      end
    end
  end
end
