module Evidence
  module Rules
    class NationalSavingsAccount < Rule
      include Evidence::RuleDsl

      key :capital_nsa_19
      group :capital

      client do |_crime_application, applicant|
        applicant.savings(SavingType::NATIONAL_SAVINGS_OR_POST_OFFICE).any?
      end

      partner do |_crime_application, partner|
        partner.present? && partner.savings(
          SavingType::NATIONAL_SAVINGS_OR_POST_OFFICE
        ).any?
      end
    end
  end
end
