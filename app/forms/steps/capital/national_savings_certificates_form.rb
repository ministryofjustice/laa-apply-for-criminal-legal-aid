module Steps
  module Capital
    class NationalSavingsCertificatesForm < Steps::BaseFormObject
      include TypeOfMeansAssessment
      include OwnershipConfirmation

      delegate :national_savings_certificate_type, to: :record

      attribute :holder_number, :string
      attribute :certificate_number, :string
      attribute :value, :pence

      validates :holder_number, :certificate_number, :value, presence: true

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
