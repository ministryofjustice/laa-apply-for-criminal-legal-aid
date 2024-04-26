module Evidence
  module Rules
    class CashInvestments < Rule
      include Evidence::RuleDsl

      key :capital_cash_investments_20
      group :capital

      client do |crime_application|
        if crime_application.savings
          crime_application.savings.where(saving_type: SavingType::OTHER.value).size.positive?
        else
          false
        end
      end

      # TODO: Awaiting partner implementation
      partner do |_crime_application|
        false
      end
    end
  end
end
