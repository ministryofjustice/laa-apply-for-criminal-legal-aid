module Steps
  module Capital
    class HasNationalSavingsCertificatesForm < Steps::BaseFormObject
      include Steps::HasOneAssociation
      include TypeOfMeansAssessment
      include Steps::ApplicantOrPartner

      has_one_association :capital

      attr_reader :national_savings_certificate

      attribute :has_national_savings_certificates, :value_object, source: YesNoAnswer

      validate :has_national_savings_certificates_selected

      private

      def persist!
        capital.update(has_national_savings_certificates:)

        return true if has_national_savings_certificates.no?

        @national_savings_certificate = incomplete_national_savings_certificate ||
                                        NationalSavingsCertificate.create!(crime_application:)
      end

      def incomplete_national_savings_certificate
        crime_application.national_savings_certificates.reject(&:complete?).first
      end

      def has_national_savings_certificates_selected
        return if YesNoAnswer.values.include?(has_national_savings_certificates) # rubocop:disable Performance/InefficientHashSearch

        errors.add(:has_national_savings_certificates, :blank, subject:)
      end
    end
  end
end
