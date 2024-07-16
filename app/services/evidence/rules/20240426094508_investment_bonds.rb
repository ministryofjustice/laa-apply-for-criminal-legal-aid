module Evidence
  module Rules
    class InvestmentBonds < Rule
      include Evidence::RuleDsl

      key :capital_investment_bonds_28
      group :capital

      client do |crime_application, applicant|
        MeansStatus.full_capital_required?(crime_application) &&
          (applicant.joint_investments.bond.any? || applicant.investments.bond.any?)
      end

      partner do |crime_application, partner|
        MeansStatus.include_partner?(crime_application) &&
          MeansStatus.full_capital_required?(crime_application) &&
          (partner.joint_investments.bond.any? || partner.investments.bond.any?)
      end
    end
  end
end
