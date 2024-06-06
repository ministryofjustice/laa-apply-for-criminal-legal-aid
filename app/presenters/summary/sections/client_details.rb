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
                         change_path: edit_steps_client_has_nino_path
                       ))
        end

        unless no_benefit?
          answers.push(Components::ValueAnswer.new(
                         :passporting_benefit, applicant.benefit_type,
                         change_path: edit_steps_dwp_benefit_type_path
                       ))
        end

        if jsa?
          answers.push(Components::DateAnswer.new(
                         :last_jsa_appointment_date, applicant.last_jsa_appointment_date,
                         change_path: edit_steps_dwp_benefit_type_path
                       ))
        end

        answers.push(
          Components::ValueAnswer.new(
            :client_has_partner,
            crime_application.client_has_partner,
            change_path: edit_steps_client_has_partner_path
          )
        )

        if no_partner?
          answers.push(
            Components::ValueAnswer.new(
              :client_relationship_status,
              crime_application.partner_detail&.relationship_status,
              change_path: edit_steps_client_relationship_status_path,
              show: crime_application.partner_detail&.relationship_status.present?
            )
          )
        end

        if crime_application.client_separated?
          answers.push(
            Components::DateAnswer.new(
              :client_relationship_separated_date,
              crime_application.partner_detail&.separated_date,
              change_path: edit_steps_client_relationship_status_path,
              show: crime_application.partner_detail&.separated_date.present?
            )
          )
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
        crime_application.pse?
      end

      def no_benefit?
        crime_application.applicant.benefit_type.nil?
      end

      def jsa?
        crime_application.applicant.benefit_type == 'jsa'
      end

      def no_partner?
        crime_application.client_has_partner == 'no'
      end
    end
  end
end
