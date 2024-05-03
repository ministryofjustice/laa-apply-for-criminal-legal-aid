module Steps
  module DWP
    class BenefitCheckResultController < Steps::DWPStepController
      include Steps::NoOpAdvanceStep

      private

      def advance_as
        :benefit_check_result
      end
    end
  end
end
