module Evidence
  module Rules
    class OtherLumpSums < Rule
      include Evidence::RuleDsl

      key :capital_other_lump_sums_29
      group :capital

      client do |_crime_application, applicant|
        applicant.investments(InvestmentType::OTHER).any?
      end

      partner do |_crime_application, partner|
        partner.present? && partner.investments(InvestmentType::OTHER).any?
      end
    end
  end
end
