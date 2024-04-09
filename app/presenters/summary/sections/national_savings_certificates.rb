module Summary
  module Sections
    class NationalSavingsCertificates < Sections::BaseSection
      def show?
        capital && requires_full_capital
      end

      def answers
        if national_savings_certificates.empty?
          [
            Components::ValueAnswer.new(
              :has_national_savings_certificate, 'no',
              change_path: edit_steps_capital_has_national_savings_certificates_path
            )
          ]
        else
          Summary::Components::NationalSavingsCertificate.with_collection(
            national_savings_certificates, show_actions: editable?, show_record_actions: headless?
          )
        end
      end

      def list?
        return false if national_savings_certificates.empty?

        true
      end

      private

      def national_savings_certificates
        @national_savings_certificates ||= crime_application.national_savings_certificates
      end

      def capital
        @capital ||= crime_application.capital
      end

      def requires_full_capital
        [
          CaseType::EITHER_WAY.to_s,
          CaseType::INDICTABLE.to_s,
          CaseType::ALREADY_IN_CROWN_COURT.to_s
        ].include?(crime_application.case.case_type)
      end
    end
  end
end
