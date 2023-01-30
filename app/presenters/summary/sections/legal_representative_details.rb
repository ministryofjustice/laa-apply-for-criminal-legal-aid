module Summary
  module Sections
    class LegalRepresentativeDetails < Sections::BaseSection
      def name
        :legal_representative_details
      end

      def show?
        provider_details.present? && super
      end

      # rubocop:disable Metrics/MethodLength
      def answers
        [
          Components::FreeTextAnswer.new(
            :office_code, provider_details.office_code,
          ),

          Components::FreeTextAnswer.new(
            :provider_email, provider_details.provider_email,
          ),

          Components::FreeTextAnswer.new(
            :legal_rep_first_name, provider_details.legal_rep_first_name,
          ),

          Components::FreeTextAnswer.new(
            :legal_rep_last_name, provider_details.legal_rep_last_name,
          ),

          Components::FreeTextAnswer.new(
            :legal_rep_telephone, provider_details.legal_rep_telephone, show: true,
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
