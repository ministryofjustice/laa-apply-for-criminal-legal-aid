module Summary
  module Sections
    class NationalSavingsCertificates < Sections::CapitalLoopBase
      def answers
        if records.empty?
          [
            Components::ValueAnswer.new(
              :has_national_savings_certificate, 'no',
              change_path: edit_steps_capital_has_national_savings_certificates_path
            )
          ]
        else
          Summary::Components::NationalSavingsCertificate.with_collection(
            records, show_actions: editable?, show_record_actions: headless?
          )
        end
      end

      private

      def records
        @records ||= crime_application.national_savings_certificates
      end
    end
  end
end
