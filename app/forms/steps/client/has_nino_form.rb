module Steps
  module Client
    class HasNinoForm < Steps::BaseFormObject
      include Steps::HasOneAssociation

      # taken from Civil Apply
      NINO_REGEXP = /\A[A-CEGHJ-PR-TW-Z]{1}[A-CEGHJ-NPR-TW-Z]{1}[0-9]{6}[A-DFM]{1}\Z/

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
