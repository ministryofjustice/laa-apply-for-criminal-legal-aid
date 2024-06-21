module Evidence
  module Rules
    class TrustFund < Rule
      include Evidence::RuleDsl

      key :income_trust_10
      group :income

      client do |crime_application|
        if crime_application.capital
          dividend = crime_application.capital.trust_fund_yearly_dividend

          crime_application.capital.will_benefit_from_trust_fund == 'yes' &&
            dividend.present? &&
            dividend.value.positive?
        else
          false
        end
      end

      partner do |crime_application|
        if MeansStatus.include_partner?(crime_application) && crime_application.capital
          dividend = crime_application.capital.partner_trust_fund_yearly_dividend

          crime_application.capital.partner_will_benefit_from_trust_fund == 'yes' &&
            dividend.present? &&
            dividend.value.positive?
        else
          false
        end
      end
    end
  end
end
