module Steps
  module Client
    class BenefitCheckResultController < Steps::ClientStepController
      include Steps::NoOpAdvanceStep

      private

      def advance_as
        :benefit_check_result
      end
    end
  end
end
