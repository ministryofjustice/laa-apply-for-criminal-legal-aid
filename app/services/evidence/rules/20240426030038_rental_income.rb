module Evidence
  module Rules
    class RentalIncome < Rule
      include Evidence::RuleDsl

      key :income_rent_8
      group :income

      client do |crime_application|
        crime_application.income&.client_rent_payment.present?
      end

      partner do |crime_application|
        crime_application.income&.partner_rent_payment.present?
      end
    end
  end
end
