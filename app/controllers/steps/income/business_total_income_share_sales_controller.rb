module Steps
  module Income
    class BusinessTotalIncomeShareSalesController < Steps::BaseStepController
      include SubjectResource
      include BusinessResource

      def edit
        @form_object = BusinessTotalIncomeShareSalesForm.build(
          business_record,
          crime_application: current_crime_application
        )
      end

      def update
        update_and_advance(
          BusinessTotalIncomeShareSalesForm,
          record: business_record,
          as: :business_total_income_share_sales
        )
      end

      private

      def additional_permitted_params
        [:total_income_share_sales_amount]
      end
    end
  end
end
