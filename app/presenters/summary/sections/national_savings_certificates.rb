module Summary
  module Sections
    class NationalSavingsCertificates < BaseCapitalRecordsSection
      private

      def has_no_records_component
        Components::ValueAnswer.new(
          :has_national_savings_certificate, has_records_answer,
          change_path: edit_steps_capital_has_national_savings_certificates_path
        )
      end

      def list_component
        Summary::Components::NationalSavingsCertificate.with_collection(
          records, show_actions: editable?, show_record_actions: headless?
        )
      end

      def records
        @records ||= capital.national_savings_certificates
      end

      def has_records_answer
        capital.has_national_savings_certificates
      end
    end
  end
end
