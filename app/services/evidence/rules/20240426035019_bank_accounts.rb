module Evidence
  module Rules
    class BankAccounts < Rule
      include Evidence::RuleDsl

      key :capital_bank_accounts_16
      group :capital

      client do |_crime_application, applicant|
        applicant.savings(SavingType::BANK).any?
      end

      partner do |_crime_application, partner|
        partner.present? && partner.savings(SavingType::BANK).any?
      end
    end
  end
end
