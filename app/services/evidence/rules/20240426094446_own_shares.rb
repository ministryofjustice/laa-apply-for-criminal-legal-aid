module Evidence
  module Rules
    class OwnShares < Rule
      include Evidence::RuleDsl

      key :capital_shares_24
      group :capital

      client do |_crime_application, applicant|
        applicant.joint_investments.share.any? || applicant.investments.share.any?
      end

      partner do |_crime_application, partner|
        partner.joint_investments.share.any? || partner.investments.share.any?
      end
    end
  end
end
