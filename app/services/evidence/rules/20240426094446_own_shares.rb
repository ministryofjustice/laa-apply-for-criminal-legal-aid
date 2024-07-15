module Evidence
  module Rules
    class OwnShares < Rule
      include Evidence::RuleDsl

      key :capital_shares_24
      group :capital

      client do |crime_application, applicant|
        MeansStatus.full_capital_required?(crime_application) &&
          (applicant.joint_investments.share.any? || applicant.investments.share.any?)
      end

      partner do |crime_application, partner|
        MeansStatus.full_capital_required?(crime_application) &&
          MeansStatus.include_partner?(crime_application) &&
          (partner.joint_investments.share.any? || partner.investments.share.any?)
      end
    end
  end
end
