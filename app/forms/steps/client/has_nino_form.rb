module Steps
  module Client
    class HasNinoForm < Steps::BaseFormObject
      include Steps::HasOneAssociation

      NINO_REGEXP = /\A(?!BG)(?!GB)(?!NK)(?!KN)(?!TN)(?!NT)(?!ZZ)[A-CEGHJ-PR-TW-Z][A-CEGHJ-NPR-TW-Z][0-9]{6}([A-DFM])\Z/

      attribute :nino, :string

      has_one_association :applicant

      validates :nino, format: { with: NINO_REGEXP }

      def nino=(str)
        super(str.upcase.delete(' ')) if str
      end

      private

      def persist!
        applicant.update(
          attributes
        )
      end
    end
  end
end
