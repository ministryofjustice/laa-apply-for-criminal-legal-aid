module Summary
  module Sections
    class ClientDetails < Sections::BaseSection
      def name
        :client_details
      end

      def show?
        applicant.present? && super
      end

      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      def answers
        [
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

          Components::FreeTextAnswer.new(
            :nino, applicant.nino,
            change_path: edit_steps_client_has_nino_path
          ),

          Components::ValueAnswer.new(
            :passporting_benefit, applicant.benefit_type,
            change_path: edit_steps_client_benefit_type_path
          ),
        ].select(&:show?)
      end
      # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

      private

      def applicant
        @applicant ||= crime_application.applicant
      end
    end
  end
end
