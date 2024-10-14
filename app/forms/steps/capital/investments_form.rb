module Steps
  module Capital
    class InvestmentsForm < Steps::BaseFormObject
      include TypeOfMeansAssessment
      include OwnershipConfirmation
      include ApplicantOrPartner

      delegate :investment_type, to: :record

      attribute :description, :string
      attribute :value, :pence

      validates :description, presence: true

      validates :value, numericality: {
        greater_than: 0,
        less_than_or_equal_to: 99_999_999.99
      }

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
