module Steps
  module Client
    class RetryBenefitCheckController < Steps::ClientStepController
      include Steps::NoOpAdvanceStep

      def update
        return redirect_to Settings.eforms_url, allow_other_host: true if params.key?(:commit_draft)

        super
      end

      private

      def advance_as
        :retry_benefit_check
      end
    end
  end
end
