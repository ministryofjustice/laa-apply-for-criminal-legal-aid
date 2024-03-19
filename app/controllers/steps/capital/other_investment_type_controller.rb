module Steps
  module Capital
    class OtherInvestmentTypeController < InvestmentTypeController
      def edit
        @form_object = OtherInvestmentTypeForm.build(
          current_crime_application
        )
      end

      def update
        update_and_advance(OtherInvestmentTypeForm, as: :investment_type)
      end
    end
  end
end
