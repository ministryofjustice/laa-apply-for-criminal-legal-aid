module Summary
  module Sections
    class LegalRepresentativeDetails < Sections::BaseSection
      def show?
        !crime_application.in_progress? && super
      end

      def answers
        [
          Components::FreeTextAnswer.new(
            :legal_rep_first_name, provider_details.legal_rep_first_name,
          ),

          Components::FreeTextAnswer.new(
            :legal_rep_last_name, provider_details.legal_rep_last_name,
          ),

          Components::FreeTextAnswer.new(
            :legal_rep_telephone, provider_details.legal_rep_telephone,
          ),
        ].select(&:show?)
      end

      private

      def provider_details
        @provider_details ||= crime_application.provider_details
      end
    end
  end
end
