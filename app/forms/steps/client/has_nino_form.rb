module Steps
  module Client
    class HasNinoForm < Steps::BaseFormObject
      include Steps::HasOneAssociation
      has_one_association :applicant

      NINO_REGEXP = /\A(?!BG)(?!GB)(?!NK)(?!KN)(?!TN)(?!NT)(?!ZZ)[A-CEGHJ-PR-TW-Z][A-CEGHJ-NPR-TW-Z][0-9]{6}([A-DFM])\z/

      attribute :nino, :string
      validate :validate_nino

      def nino=(str)
        super(str.upcase.delete(' ')) if str
      end

      private

      def validate_nino
        if nino.blank?
          crime_application.not_means_tested? ? return : errors.add(:nino, :blank)
        end

        errors.add(:nino, :invalid) unless NINO_REGEXP.match?(nino)
      end

      def persist!
        return true unless changed?

        applicant.update(
          attributes.merge(
            # The following are dependent attributes that need to be reset
            benefit_type: nil,
            passporting_benefit: nil,
          )
        )
      end
    end
  end
end
