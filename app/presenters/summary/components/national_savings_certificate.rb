module Summary
  module Components
    class NationalSavingsCertificate < BaseRecord
      GROUP_BY = :id

      alias national_savings_certificate record

      private

      def answers # rubocop:disable Metrics/MethodLength
        [
          Components::FreeTextAnswer.new(
            :national_savings_certificate_holder_number,
            national_savings_certificate.holder_number
          ),
          Components::FreeTextAnswer.new(
            :national_savings_certificate_certificate_number,
            national_savings_certificate.certificate_number
          ),
          Components::MoneyAnswer.new(
            :national_savings_certificate_value,
            national_savings_certificate.value
          ),
          Components::ValueAnswer.new(
            :national_savings_certificate_ownership_type,
            national_savings_certificate.ownership_type
          )
        ]
      end

      def name
        I18n.t('summary.sections.national_savings_certificate')
      end

      def change_path
        edit_steps_capital_national_savings_certificates_path(
          national_savings_certificate_id: record.id
        )
      end

      def summary_path
        edit_steps_capital_national_savings_certificates_summary_path
      end

      def remove_path
        confirm_destroy_steps_capital_national_savings_certificates_path(
          national_savings_certificate_id: record.id
        )
      end
    end
  end
end
