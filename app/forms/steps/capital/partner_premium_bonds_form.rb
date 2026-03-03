module Steps
  module Capital
    class PartnerPremiumBondsForm < Steps::BaseFormObject
      include Steps::HasOneAssociation

      has_one_association :capital

      attribute :partner_has_premium_bonds, :value_object, source: YesNoAnswer
      attribute :partner_premium_bonds_total_value, :pence
      attribute :partner_premium_bonds_holder_number, :string

      validates :partner_has_premium_bonds, inclusion: { in: YesNoAnswer.values }

      validates(
        :partner_premium_bonds_total_value,
        :partner_premium_bonds_holder_number,
        presence: true,
        if: -> { partner_has_premium_bonds&.yes? }
      )

      private

      def persist!
        capital.update(attributes)
      end

      def before_save
        return if partner_has_premium_bonds&.yes?

        self.partner_premium_bonds_total_value = nil
        self.partner_premium_bonds_holder_number = nil
      end
    end
  end
end
