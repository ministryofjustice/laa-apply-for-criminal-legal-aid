module Steps
  module Capital
    class HasNationalSavingsCertificatesForm < Steps::BaseFormObject
      include Steps::HasOneAssociation
      has_one_association :capital

      attr_reader :national_savings_certificate

      attribute :has_national_savings_certificates, :value_object, source: YesNoAnswer

      validates :has_national_savings_certificates, inclusion: { in: YesNoAnswer.values }

      private

      def persist!
        return true if has_national_savings_certificates.no?

        @national_savings_certificate = incomplete_national_savings_certificate ||
                                        NationalSavingsCertificate.create!(crime_application:)
      end

      def incomplete_national_savings_certificate
        crime_application.national_savings_certificates.reject(&:complete?).first
      end
    end
  end
end
