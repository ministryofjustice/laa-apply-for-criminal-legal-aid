module Steps
  module DWP
    class RetryBenefitCheckController < Steps::DWPStepController
      include Steps::NoOpAdvanceStep

      private

      def advance_as
        :retry_benefit_check
      end
    end
  end
end
