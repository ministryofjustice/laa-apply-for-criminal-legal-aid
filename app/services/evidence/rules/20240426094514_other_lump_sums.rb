module Evidence
  module Rules
    class OtherLumpSums < Rule
      include Evidence::RuleDsl

      key :capital_other_lump_sums_29
      group :capital

      client do |crime_application|
        crime_application.capital&.client_other_investments.present?
      end

      partner do |crime_application|
        crime_application.capital&.partner_other_investments.present?
      end
    end
  end
end
