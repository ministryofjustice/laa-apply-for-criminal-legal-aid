module Evidence
  module Rules
    class ShareIsa < Rule
      include Evidence::RuleDsl

      key :capital_share_isa_26
      group :capital

      client do |_crime_application, applicant|
        applicant.joint_investments.share_isa.any? || applicant.investments.share_isa.any?
      end

      partner do |_crime_application, partner|
        partner.joint_investments.share_isa.any? || partner.investments.share_isa.any?
      end
    end
  end
end
