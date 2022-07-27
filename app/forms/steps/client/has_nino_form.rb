module Steps
  module Client
    class HasNinoForm < Steps::BaseFormObject
      include Steps::HasOneAssociation

      # taken from Civil Apply
      NINO_REGEXP = /\A[A-CEGHJ-PR-TW-Z]{1}[A-CEGHJ-NPR-TW-Z]{1}[0-9]{6}[A-DFM]{1}\Z/

      attribute :has_nino, :yes_no
      attribute :nino, :string

      has_one_association :applicant_details

      validates_inclusion_of :has_nino, in: :choices
      validates :nino, format: { with: NINO_REGEXP }, if: -> { has_nino&.yes? }

      def choices
        YesNoAnswer.values
      end

      private

      def persist!
        applicant_details.update(
          attributes
        )
      end
    end
  end
end
