module Evidence
  module Rules
    class OwnShares < Rule
      include Evidence::RuleDsl

      key :capital_shares_24
      group :capital

      client do |_crime_application, applicant|
        applicant.investments(InvestmentType::SHARE).any?
      end

      partner do |_crime_application, partner|
        partner.present? && partner.investments(InvestmentType::SHARE).any?
      end
    end
  end
end
