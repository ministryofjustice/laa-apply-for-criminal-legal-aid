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
            change_path: edit_steps_client_details_path,
            i18n_opts: { format: :dob }
          ),
        ]

        unless nino_not_required?
          answers.push(Components::FreeTextAnswer.new(
                         :nino, applicant.nino,
                         change_path: edit_steps_nino_path(subject: 'client'),
                         show: true
                       ))

          answers.push(Components::FreeTextAnswer.new(
                         :arc, applicant.arc,
                         change_path: edit_steps_nino_path(subject: 'client'),
                       ))
        end

        answers.push(
          Components::ValueAnswer.new(
            :has_partner,
            crime_application.applicant.has_partner,
            change_path: edit_steps_client_has_partner_path
          )
        )

        if no_partner?
          answers.push(
            Components::ValueAnswer.new(
              :relationship_status,
              crime_application.applicant.relationship_status,
              change_path: edit_steps_client_relationship_status_path,
            )
          )

          answers.push(
            Components::DateAnswer.new(
              :separation_date,
              crime_application.applicant.separation_date,
              change_path: edit_steps_client_relationship_status_path,
              show: client_separated?,
            )
          )
        end

        answers.select(&:show?)
      end
      # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

      def editable?
        crime_application.initial? && super
      end

      private

      def applicant
        @applicant ||= crime_application.applicant
      end

      def no_partner?
        crime_application.applicant.has_partner == 'no'
      end

      def client_separated?
        crime_application.applicant.relationship_status == ClientRelationshipStatusType::SEPARATED.to_s
      end

      def nino_not_required?
        crime_application.pse? || crime_application.appeal_no_changes? ||
          crime_application.means_passport.include?(MeansPassportType::ON_AGE_UNDER18.to_s)
      end
    end
  end
end
