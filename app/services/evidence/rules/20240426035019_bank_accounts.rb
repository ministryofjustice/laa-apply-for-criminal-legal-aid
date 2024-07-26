module Evidence
  module Rules
    class BankAccounts < Rule
      include Evidence::RuleDsl

      key :capital_bank_accounts_16
      group :capital

      client do |crime_application|
        crime_application.capital&.client_bank_savings.present?
      end

      partner do |crime_application|
        crime_application.capital&.partner_bank_savings.present?
      end
    end
  end
end
