module Evidence
  module Rules
    class CashInvestments < Rule
      include Evidence::RuleDsl

      key :capital_cash_investments_20
      group :capital

      client do |crime_application|
        crime_application.savings.for_client.where(saving_type: SavingType::OTHER.value).any?
      end

      partner do |crime_application|
        crime_application.savings.for_partner.where(saving_type: SavingType::OTHER.value).any?
      end
    end
  end
end
