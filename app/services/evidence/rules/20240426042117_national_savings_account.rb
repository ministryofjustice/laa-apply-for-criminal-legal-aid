module Evidence
  module Rules
    class NationalSavingsAccount < Rule
      include Evidence::RuleDsl

      key :capital_nsa_19
      group :capital

      client do |crime_application|
        crime_application.capital&.client_national_savings_or_post_office_savings.present?
      end

      partner do |crime_application|
        crime_application.capital&.partner_national_savings_or_post_office_savings.present?
      end
    end
  end
end
