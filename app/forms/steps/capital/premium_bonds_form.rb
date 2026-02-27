module Steps
  module Capital
    class PremiumBondsForm < Steps::BaseFormObject
      include Steps::HasOneAssociation

      has_one_association :capital

      attribute :has_premium_bonds, :value_object, source: YesNoAnswer
      attribute :premium_bonds_total_value, :pence
      attribute :premium_bonds_holder_number, :string

      validates :has_premium_bonds, inclusion: { in: YesNoAnswer.values }

      validates(
        :premium_bonds_total_value,
        :premium_bonds_holder_number,
        presence: true,
        if: -> { has_premium_bonds&.yes? }
      )

      private

      def persist!
        capital.update(attributes)
      end

      def before_save
        return if has_premium_bonds&.yes?

        self.premium_bonds_total_value = nil
        self.premium_bonds_holder_number = nil
      end
    end
  end
end
