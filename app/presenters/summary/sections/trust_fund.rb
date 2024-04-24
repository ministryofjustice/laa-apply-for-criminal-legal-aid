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
            cast_to_pounds(crime_application.capital.trust_fund_amount_held),
            change_path: change_path,
            show: will_benefit_from_trust_fund?
          ),
          Components::MoneyAnswer.new(
            :trust_fund_yearly_dividend,
            cast_to_pounds(crime_application.capital.trust_fund_yearly_dividend),
            change_path: change_path,
            show: will_benefit_from_trust_fund?
          )
        ].select(&:show?)
      end

      private

      # TODO: figure out why casting from pence is not happening automatically
      def cast_to_pounds(value)
        Money.new(value)
      end

      def will_benefit_from_trust_fund?
        YesNoAnswer.new(capital.will_benefit_from_trust_fund.to_s).yes?
      end

      def change_path
        edit_steps_capital_trust_fund_path(crime_application)
      end

      def capital
        @capital ||= crime_application.capital
      end
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
  end
end
