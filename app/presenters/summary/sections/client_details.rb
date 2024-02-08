module Summary
  module Sections
    class ClientDetails < Sections::BaseSection
      def show?
        applicant.present? && super
      end

      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      def answers
        answers = [
          Components::FreeTextAnswer.new(
            :first_name, applicant.first_name,
            change_path: edit_steps_client_details_path
          ),

          Components::FreeTextAnswer.new(
            :last_name, applicant.last_name,
            change_path: edit_steps_client_details_path
          ),

          Components::FreeTextAnswer.new(
            :other_names, applicant.other_names,
            change_path: edit_steps_client_details_path, show: true
          ),

          Components::DateAnswer.new(
            :date_of_birth, applicant.date_of_birth,
            change_path: edit_steps_client_details_path
          ),
        ]

        unless post_submission_evidence?
          answers.push(Components::FreeTextAnswer.new(
                         :nino, applicant.nino,
                         change_path: edit_steps_client_has_nino_path, show: true
                       ))
        end

        unless no_benefit?
          answers.push(Components::ValueAnswer.new(
                         :passporting_benefit, applicant.benefit_type,
                         change_path: edit_steps_client_benefit_type_path
                       ))
        end

        answers.select(&:show?)
        answers
      end
      # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

      def editable?
        crime_application.initial? && super
      end

      private

      def applicant
        @applicant ||= crime_application.applicant
      end

      def post_submission_evidence?
        crime_application.application_type == ApplicationType::POST_SUBMISSION_EVIDENCE.to_s
      end

      def no_benefit?
        crime_application.applicant.benefit_type.nil?
      end
    end
  end
end
