module Evidence
  module Rules
    class OtherLumpSums < Rule
      include Evidence::RuleDsl

      key :capital_other_lump_sums_29
      group :capital

      client do |crime_application|
        crime_application.investments.for_client.where(investment_type: InvestmentType::OTHER.value).any?
      end

      partner do |crime_application|
        crime_application.investments.for_partner.where(investment_type: InvestmentType::OTHER.value).any?
      end
    end
  end
end
