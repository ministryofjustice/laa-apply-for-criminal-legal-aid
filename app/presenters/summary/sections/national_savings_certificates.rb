module Summary
  module Sections
    class NationalSavingsCertificates < Sections::CapitalLoopBase
      private

      def records
        @records ||= crime_application.national_savings_certificates
      end

      def question
        :has_national_savings_certificate
      end

      def edit_path
        edit_steps_capital_national_savings_certificates_summary_path
      end

      def list_component
        Summary::Components::NationalSavingsCertificate.with_collection(
          records, show_actions: editable?, show_record_actions: headless?
        )
      end

      def absence_answer
        'no'
      end
    end
  end
end
