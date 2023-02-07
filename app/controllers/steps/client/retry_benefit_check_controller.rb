module Steps
  module Client
    class RetryBenefitCheckController < Steps::ClientStepController
      def edit
        @form_object = RetryBenefitCheckForm.build(
          current_crime_application
        )
      end

      def update
        return redirect_to Settings.eforms_url, allow_other_host: true if params.key?(:commit_draft)

        update_and_advance(RetryBenefitCheckForm, as: :retry_benefit_check)
      end
    end
  end
end
