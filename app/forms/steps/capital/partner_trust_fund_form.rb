module Steps
  module Capital
    class PartnerTrustFundForm < Steps::BaseFormObject
      include Steps::HasOneAssociation
      has_one_association :capital

      attribute :partner_will_benefit_from_trust_fund, :value_object, source: YesNoAnswer
      attribute :partner_trust_fund_amount_held, :pence
      attribute :partner_trust_fund_yearly_dividend, :pence

      validates :partner_will_benefit_from_trust_fund, inclusion: { in: YesNoAnswer.values }

      validates :partner_trust_fund_amount_held, numericality: {
        greater_than: 0,
        less_than_or_equal_to: 99_999_999.99
      }, if: -> { partner_will_benefit_from_trust_fund&.yes? }

      validates :partner_trust_fund_yearly_dividend, numericality {
        greater_than_or_equal_to: 0,
        less_than_or_equal_to: 99_999_999.99
      }, if: -> { partner_will_benefit_from_trust_fund&.yes? }


      private

      def persist!
        capital.update(attributes)
      end

      def before_save
        return if partner_will_benefit_from_trust_fund&.yes?

        self.partner_trust_fund_amount_held = nil
        self.partner_trust_fund_yearly_dividend = nil
      end
    end
  end
end
