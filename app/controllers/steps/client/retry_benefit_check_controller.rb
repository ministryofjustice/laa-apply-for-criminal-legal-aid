module Steps
  module Client
    class RetryBenefitCheckController < Steps::ClientStepController
      include Steps::NoOpAdvanceStep

      private

      def advance_as
        :retry_benefit_check
      end
    end
  end
end
