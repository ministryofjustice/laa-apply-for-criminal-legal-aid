module Steps
  module Income
    class UsualPropertyDetailsController < Steps::IncomeStepController
      include Steps::UsualPropertyDetailsStep

      private

      def form_name
        UsualPropertyDetailsForm
      end
    end
  end
end
