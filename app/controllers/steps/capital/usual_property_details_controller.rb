module Steps
  module Capital
    class UsualPropertyDetailsController < Steps::CapitalStepController
      include Steps::UsualPropertyDetailsStep

      private

      def form_name
        UsualPropertyDetailsForm
      end
    end
  end
end
