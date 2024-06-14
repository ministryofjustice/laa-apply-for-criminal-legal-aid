module Evidence
  module Rules
    class RentalIncome < Rule
      include Evidence::RuleDsl

      key :income_rent_8
      group :income

      client do |_crime_application, applicant|
        applicant.income_payments.rent.present?
      end

      partner do |_crime_application, partner|
        partner.income_payments.rent.present?
      end
    end
  end
end
