module Steps
  module Client
    class HasNinoForm < Steps::BaseFormObject
      include Steps::HasOneAssociation

      # taken from Civil Apply
      NINO_REGEXP = /\A(?!BG)(?!GB)(?!NK)(?!KN)(?!TN)(?!NT)(?!ZZ)(?:[A-CEGHJ-PR-TW-Z][A-CEGHJ-NPR-TW-Z])(?:\s*\d\s*){6}([A-DFM]|\s)\Z/

      attribute :nino, :string

      has_one_association :applicant

      validates :nino, format: { with: NINO_REGEXP }

      private

      def persist!
        applicant.update(
          attributes
        )
      end
    end
  end
end
