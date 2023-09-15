module Steps
  module Client
    class HasNinoForm < Steps::BaseFormObject
      include Steps::HasOneAssociation
      has_one_association :applicant

      NINO_REGEXP = /\A(?!BG)(?!GB)(?!NK)(?!KN)(?!TN)(?!NT)(?!ZZ)[A-CEGHJ-PR-TW-Z][A-CEGHJ-NPR-TW-Z][0-9]{6}([A-DFM])\z/

      attribute :nino, :string
      validates :nino, format: { with: NINO_REGEXP }

      def nino=(str)
        super(str.upcase.delete(' ')) if str
      end

      private

      def persist!
        return true unless changed?

        applicant.update(
          attributes.merge(
            # The following are dependent attributes that need to be reset
            passporting_benefit: nil,
          )
        )
      end
    end
  end
end
