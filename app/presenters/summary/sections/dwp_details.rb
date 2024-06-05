module Summary
  module Sections
    class DWPDetails < Sections::BaseSection
      def show?
        benefit_check_recipient.present? && super
      end

      # rubocop:disable Metrics/MethodLength
      def answers
        [
          Components::FreeTextAnswer.new(
            :first_name, benefit_check_recipient.first_name
          ),

          Components::FreeTextAnswer.new(
            :last_name, benefit_check_recipient.last_name
          ),

          Components::FreeTextAnswer.new(
            :other_names, benefit_check_recipient.other_names, show: true
          ),

          Components::DateAnswer.new(
            :date_of_birth, benefit_check_recipient.date_of_birth
          ),

          Components::FreeTextAnswer.new(
            :nino, benefit_check_recipient.nino
          ),
        ].select(&:show?)
      end
      # rubocop:enable Metrics/MethodLength

      def name
        :details
      end

      private

      def benefit_check_recipient
        @benefit_check_recipient ||= crime_application.benefit_check_recipient
      end
    end
  end
end
