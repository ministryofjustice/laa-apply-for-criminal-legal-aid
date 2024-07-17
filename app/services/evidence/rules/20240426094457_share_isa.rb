module Evidence
  module Rules
    class ShareIsa < Rule
      include Evidence::RuleDsl

      key :capital_share_isa_26
      group :capital

      client do |_crime_application, applicant|
        applicant.investments(InvestmentType::SHARE_ISA).any?
      end

      partner do |_crime_application, partner|
        partner.present? && partner.investments(InvestmentType::SHARE_ISA).any?
      end
    end
  end
end
