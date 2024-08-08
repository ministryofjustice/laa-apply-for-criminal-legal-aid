module Evidence
  module Rules
    class TrustFund < Rule
      include Evidence::RuleDsl

      key :income_trust_10
      group :income

      client do |crime_application|
        crime_application.capital&.will_benefit_from_trust_fund == 'yes' &&
          !crime_application.capital.trust_fund_yearly_dividend.value.nil?
      end

      partner do |crime_application|
        crime_application.capital&.partner_will_benefit_from_trust_fund == 'yes' &&
          !crime_application.capital.partner_trust_fund_yearly_dividend.value.nil?
      end
    end
  end
end
