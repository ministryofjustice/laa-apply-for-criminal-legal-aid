module Evidence
  module Rules
    class BankAccounts < Rule
      include Evidence::RuleDsl

      key :capital_bank_accounts_16
      group :capital

      client do |crime_application|
        crime_application.savings.for_client.where(saving_type: SavingType::BANK.value).any?
      end

      partner do |crime_application|
        crime_application.savings.for_partner.where(saving_type: SavingType::BANK.value).any?
      end
    end
  end
end
