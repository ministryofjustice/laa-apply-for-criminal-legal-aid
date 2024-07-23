module Steps
  module Capital
    class NationalSavingsCertificatesForm < Steps::BaseFormObject
      include TypeOfMeansAssessment
      include OwnershipConfirmation
      include ApplicantOrPartner

      # match any alphanumeric string that does not contain any special characters
      # this is to avoid modsec errors, specifically strings ending with - (dash)
      NSC_REGEXP = /\A[\w\s]+\z/

      delegate :national_savings_certificate_type, to: :record

      attribute :holder_number, :string
      attribute :certificate_number, :string
      attribute :value, :pence

      validates :holder_number, format: { with: NSC_REGEXP }, presence: true
      validates :certificate_number, :value, presence: true

      def persist!
        record.update(attributes)
      end

      private

      def before_save
        set_ownership
      end
    end
  end
end
