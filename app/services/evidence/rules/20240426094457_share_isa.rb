module Evidence
  module Rules
    class ShareIsa < Rule
      include Evidence::RuleDsl

      key :capital_share_isa_26
      group :capital

      client do |crime_application, applicant|
        MeansStatus.full_capital_required?(crime_application) &&
          (applicant.joint_investments.share_isa.any? || applicant.investments.share_isa.any?)
      end

      partner do |crime_application, partner|
        MeansStatus.full_capital_required?(crime_application) &&
          MeansStatus.include_partner?(crime_application) &&
          (partner.joint_investments.share_isa.any? || partner.investments.share_isa.any?)
      end
    end
  end
end
