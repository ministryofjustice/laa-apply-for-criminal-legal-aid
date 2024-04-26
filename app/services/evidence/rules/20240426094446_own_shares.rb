module Evidence
  module Rules
    class OwnShares < Rule
      include Evidence::RuleDsl

      key :capital_shares_24
      group :capital

      client do |crime_application|
        crime_application.investments.for_client.where(investment_type: InvestmentType::SHARE.value).any?
      end

      partner do |crime_application|
        crime_application.investments.for_partner.where(investment_type: InvestmentType::SHARE.value).any?
      end
    end
  end
end
