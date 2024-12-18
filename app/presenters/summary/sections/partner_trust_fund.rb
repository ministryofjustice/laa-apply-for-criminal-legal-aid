module Summary
  module Sections
    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    class PartnerTrustFund < Sections::BaseSection
      include HasDynamicSubject

      def show?
        capital.present? &&
          MeansStatus.include_partner?(crime_application) &&
          capital.partner_will_benefit_from_trust_fund.present?
      end

      def answers
        [
          Components::ValueAnswer.new(
            :partner_will_benefit_from_trust_fund,
            crime_application.capital.partner_will_benefit_from_trust_fund,
            change_path: edit_steps_capital_partner_trust_fund_path(crime_application),
            show: true
          ),
          Components::MoneyAnswer.new(
            :partner_trust_fund_amount_held,
            crime_application.capital.partner_trust_fund_amount_held,
            change_path: edit_steps_capital_partner_trust_fund_path(crime_application),
            show: partner_will_benefit_from_trust_fund?
          ),
          Components::MoneyAnswer.new(
            :partner_trust_fund_yearly_dividend,
            crime_application.capital.partner_trust_fund_yearly_dividend,
            change_path: edit_steps_capital_partner_trust_fund_path(crime_application),
            show: partner_will_benefit_from_trust_fund?
          )
        ].select(&:show?)
      end

      private

      def partner_will_benefit_from_trust_fund?
        YesNoAnswer.new(capital.partner_will_benefit_from_trust_fund.to_s).yes?
      end

      def subject_type
        SubjectType.new(:partner)
      end
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
  end
end
