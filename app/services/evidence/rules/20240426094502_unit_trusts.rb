module Evidence
  module Rules
    class UnitTrusts < Rule
      include Evidence::RuleDsl

      key :capital_unit_trusts_27
      group :capital

      client do |_crime_application, applicant|
        applicant.investments(InvestmentType::UNIT_TRUST).any?
      end

      partner do |_crime_application, partner|
        partner.present? && partner.investments(InvestmentType::UNIT_TRUST).any?
      end
    end
  end
end
