module Steps
  module Capital
    class NationalSavingsCertificateForm < Steps::BaseFormObject
      include Steps::Ownable 

      attribute :certificate_number, :string
      attribute :holder_number, :string
      attribute :value, :pence

      validates :certificate_number, :holder_number, :value, presence: true

      def persist!
        record.update(attributes)
      end
    end
  end
end
