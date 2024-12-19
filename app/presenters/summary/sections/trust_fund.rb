module Summary
  module Sections
    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    class TrustFund < Sections::BaseSection
      include TypeOfMeansAssessment
      include HasDynamicSubject

      def show?
        capital.present? && capital.will_benefit_from_trust_fund.present?
      end

      def answers
        [
          Components::ValueAnswer.new(
            :will_benefit_from_trust_fund,
            crime_application.capital.will_benefit_from_trust_fund,
            change_path: edit_steps_capital_trust_fund_path(crime_application),
            show: true
          ),
          Components::MoneyAnswer.new(
            :trust_fund_amount_held,
            crime_application.capital.trust_fund_amount_held,
            change_path: edit_steps_capital_trust_fund_path(crime_application),
            show: will_benefit_from_trust_fund?
          ),
          Components::MoneyAnswer.new(
            :trust_fund_yearly_dividend,
            crime_application.capital.trust_fund_yearly_dividend,
            change_path: edit_steps_capital_trust_fund_path(crime_application),
            show: will_benefit_from_trust_fund?
          )
        ].select(&:show?)
      end

      def heading
        :savings_and_investments unless requires_full_capital?
      end

      private

      def will_benefit_from_trust_fund?
        YesNoAnswer.new(capital.will_benefit_from_trust_fund.to_s).yes?
      end
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
  end
end
