module Steps
  module Client
    class HasBenefitEvidenceController < Steps::ClientStepController
      def edit
        @form_object = HasBenefitEvidenceForm.new(
          crime_application: current_crime_application
        )
      end

      def update
        expected_evidence = current_crime_application.expected_evidence || []

        expected_evidence << 'passporting_benefit' if expected_evidence.exclude?('passporting_benefit')

        current_crime_application.update(expected_evidence:)

        update_and_advance(HasBenefitEvidenceForm, as: :has_benefit_evidence)
      end
    end
  end
end
