module Summary
  module Sections
    class Overview < Sections::BaseSection
      def name
        :overview
      end

      def show?
        !crime_application.in_progress? && super
      end

      # rubocop:disable Metrics/MethodLength
      def answers
        [
          Components::FreeTextAnswer.new(
            :reference, crime_application.reference.to_s,
          ),

          Components::DateTimeAnswer.new(
            :date_stamp, crime_application.date_stamp,
          ),

          Components::DateTimeAnswer.new(
            :date_submitted, crime_application.submitted_at,
          ),

          Components::FreeTextAnswer.new(
            :provider_email, provider_details.provider_email,
          ),

          Components::FreeTextAnswer.new(
            :office_code, provider_details.office_code,
          ),
        ].select(&:show?)
      end
      # rubocop:enable Metrics/MethodLength

      private

      def provider_details
        @provider_details ||= crime_application.provider_details
      end
    end
  end
end
