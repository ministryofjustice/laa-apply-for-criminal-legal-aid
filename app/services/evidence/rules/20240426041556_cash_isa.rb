module Evidence
  module Rules
    class CashIsa < Rule
      include Evidence::RuleDsl

      key :capital_cash_isa_18
      group :capital

      client do |_crime_application, applicant|
        applicant.savings.cash_isa.any? || applicant.joint_savings.cash_isa.any?
      end

      partner do |crime_application, partner|
        MeansStatus.include_partner?(crime_application) &&
          (partner.savings.cash_isa.any? || partner.joint_savings.cash_isa.any?)
      end
    end
  end
end
