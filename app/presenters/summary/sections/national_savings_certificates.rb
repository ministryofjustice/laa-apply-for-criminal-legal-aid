module Summary
  module Sections
    class NationalSavingsCertificates < Sections::BaseSection
      def show?
        !national_savings_certificates.empty?
      end

      def answers
        Summary::Components::NationalSavingsCertificate.with_collection(
          national_savings_certificates, show_actions: editable?, show_record_actions: headless?
        )
      end

      def list?
        true
      end

      private

      def national_savings_certificates
        @national_savings_certificates ||= crime_application.national_savings_certificates
      end
    end
  end
end
