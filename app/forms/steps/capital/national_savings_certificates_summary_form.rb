module Steps
  module Capital
    class NationalSavingsCertificatesSummaryForm < Steps::BaseFormObject
      attr_reader :add_national_savings_certificate, :national_savings_certificate

      validates :add_national_savings_certificate, inclusion: { in: YesNoAnswer.values }

      delegate :national_savings_certificates, to: :crime_application

      def choices
        YesNoAnswer.values
      end

      def add_national_savings_certificate=(attribute)
        return unless attribute

        @add_national_savings_certificate = YesNoAnswer.new(attribute)
      end

      private

      def persist!
        return true if add_national_savings_certificate.no?

        @national_savings_certificate = national_savings_certificates.create!
      end
    end
  end
end
