module Evidence
  module Rules
    class ShareIsa < Rule
      include Evidence::RuleDsl

      key :capital_share_isa_26
      group :capital

      client do |crime_application|
        crime_application.investments.for_client.where(investment_type: InvestmentType::SHARE_ISA.value).any?
      end

      partner do |crime_application|
        crime_application.investments.for_partner.where(investment_type: InvestmentType::SHARE_ISA.value).any?
      end
    end
  end
end
