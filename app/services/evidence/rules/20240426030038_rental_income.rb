module Evidence
  module Rules
    class RentalIncome < Rule
      include Evidence::RuleDsl

      key :income_rent_8
      group :income

      client do |_crime_application, applicant|
        applicant.income_payments.rent.present?
      end

      partner do |crime_application, partner|
        MeansStatus.include_partner?(crime_application) &&
          partner.income_payments.rent.present?
      end
    end
  end
end
