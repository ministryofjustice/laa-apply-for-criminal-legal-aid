module Evidence
  module Rules
    class CashIsa < Rule
      include Evidence::RuleDsl

      key :capital_cash_isa_18
      group :capital

      client do |crime_application|
        if crime_application.savings
          crime_application.savings.where(saving_type: SavingType::CASH_ISA.value).size.positive?
        else
          false
        end
      end

      partner do |_crime_application|
        false
      end

      other do |_crime_application|
        # Predicate must return true or false
        false
      end
    end
  end
end
