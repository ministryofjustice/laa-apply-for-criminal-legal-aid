module Evidence
  module Rules
    class CashIsa < Rule
      include Evidence::RuleDsl

      key :capital_cash_isa_18
      group :capital

      client do |crime_application|
        crime_application.savings.for_client.where(saving_type: SavingType::CASH_ISA.value).any?
      end

      partner do |crime_application|
        crime_application.savings.for_partner.where(saving_type: SavingType::CASH_ISA.value).any?
      end
    end
  end
end
