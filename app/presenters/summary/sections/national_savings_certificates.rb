module Summary
  module Sections
    class NationalSavingsCertificates < Sections::BaseSection
      def show?
        shown_question?
      end

      def answers
        if no_certificates?
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

      def shown_question?
        capital.present? && (no_certificates? || national_savings_certificates.present?)
      end

      def no_certificates?
        return false if capital.has_national_savings_certificates.nil?

        YesNoAnswer.new(capital.has_national_savings_certificates).no?
      end
    end
  end
end
