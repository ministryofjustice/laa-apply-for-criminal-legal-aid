module Evidence
  module Rules
    class CashInvestments < Rule
      include Evidence::RuleDsl

      key :capital_cash_investments_20
      group :capital

      client do |_crime_application, applicant|
        applicant.savings(SavingType::OTHER).any?
      end

      partner do |_crime_application, partner|
        partner.present? && partner.savings(SavingType::OTHER).any?
      end
    end
  end
end
