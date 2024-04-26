module Evidence
  module Rules
    class NationalSavingsAccount < Rule
      include Evidence::RuleDsl

      key :capital_nsa_19
      group :capital

      client do |crime_application|
        crime_application.savings.for_client.where(saving_type: SavingType::NATIONAL_SAVINGS_OR_POST_OFFICE.value).any?
      end

      partner do |crime_application|
        crime_application.savings.for_partner.where(saving_type: SavingType::NATIONAL_SAVINGS_OR_POST_OFFICE.value).any?
      end
    end
  end
end
