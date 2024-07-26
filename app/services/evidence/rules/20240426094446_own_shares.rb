module Evidence
  module Rules
    class OwnShares < Rule
      include Evidence::RuleDsl

      key :capital_shares_24
      group :capital

      client do |crime_application|
        crime_application.capital&.client_share_investments.present?
      end

      partner do |crime_application|
        crime_application.capital&.partner_share_investments.present?
      end
    end
  end
end
