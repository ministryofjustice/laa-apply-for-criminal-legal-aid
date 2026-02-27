module Steps
  module Capital
    class TrustFundForm < Steps::BaseFormObject
      include Steps::HasOneAssociation

      has_one_association :capital

      attribute :will_benefit_from_trust_fund, :value_object, source: YesNoAnswer
      attribute :trust_fund_amount_held, :pence
      attribute :trust_fund_yearly_dividend, :pence

      validates :will_benefit_from_trust_fund, inclusion: { in: YesNoAnswer.values }

      validates(
        :trust_fund_amount_held,
        :trust_fund_yearly_dividend,
        presence: true,
        if: -> { will_benefit_from_trust_fund&.yes? }
      )

      private

      def persist!
        capital.update(attributes)
      end

      def before_save
        return if will_benefit_from_trust_fund&.yes?

        self.trust_fund_amount_held = nil
        self.trust_fund_yearly_dividend = nil
      end
    end
  end
end
