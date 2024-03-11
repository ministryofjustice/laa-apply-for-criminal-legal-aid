module Steps
  module Capital
    class InvestmentsForm < Steps::BaseFormObject
      include OwnershipConfirmation

      delegate :investment_type, to: :record

      attribute :description, :string
      attribute :value, :pence

      validates :description, :value, presence: true

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
