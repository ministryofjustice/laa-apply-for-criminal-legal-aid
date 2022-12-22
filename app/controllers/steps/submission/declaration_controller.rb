module Steps
  module Submission
    class DeclarationController < Steps::SubmissionStepController
      def edit
        @form_object = DeclarationForm.new(
          record: current_provider,
          crime_application: current_crime_application,
          **default_values
        )
      end

      def update
        update_and_advance(
          DeclarationForm, record: current_provider, as: :declaration
        )
      end

      private

      def default_values
        first_name = current_crime_application.legal_rep_first_name ||
                     current_provider.legal_rep_first_name

        last_name = current_crime_application.legal_rep_last_name ||
                    current_provider.legal_rep_last_name

        telephone = current_crime_application.legal_rep_telephone ||
                    current_provider.legal_rep_telephone

        {
          legal_rep_first_name: first_name,
          legal_rep_last_name: last_name,
          legal_rep_telephone: telephone,
        }
      end
    end
  end
end
