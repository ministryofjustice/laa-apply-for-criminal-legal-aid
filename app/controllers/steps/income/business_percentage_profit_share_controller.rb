module Steps
  module Income
    class BusinessPercentageProfitShareController < Steps::BaseStepController
      include SubjectResource
      include BusinessResource

      def edit
        @form_object = BusinessPercentageProfitShareForm.build(
          business_record,
          crime_application: current_crime_application
        )
      end

      def update
        update_and_advance(
          BusinessPercentageProfitShareForm,
          record: business_record,
          as: :business_percentage_profit_share
        )
      end
    end
  end
end
