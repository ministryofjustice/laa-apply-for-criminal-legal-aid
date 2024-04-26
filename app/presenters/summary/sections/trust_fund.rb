module Summary
  module Sections
    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    class TrustFund < Sections::BaseSection
      def show?
        capital.present? && super
      end

      def answers
        [
          Components::ValueAnswer.new(
            :will_benefit_from_trust_fund,
            crime_application.capital.will_benefit_from_trust_fund,
            change_path: change_path,
            show: true
          ),
          Components::MoneyAnswer.new(
            :trust_fund_amount_held,
            crime_application.capital.trust_fund_amount_held,
            change_path: change_path,
            show: will_benefit_from_trust_fund?
          ),
          Components::MoneyAnswer.new(
            :trust_fund_yearly_dividend,
            crime_application.capital.trust_fund_yearly_dividend,
            change_path: change_path,
            show: will_benefit_from_trust_fund?
          )
        ].select(&:show?)
      end

      private

      def will_benefit_from_trust_fund?
        YesNoAnswer.new(capital.will_benefit_from_trust_fund.to_s).yes?
      end

      def change_path
        edit_steps_capital_trust_fund_path(crime_application)
      end
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
  end
end
