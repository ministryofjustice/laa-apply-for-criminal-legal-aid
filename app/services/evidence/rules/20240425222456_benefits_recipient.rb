module Evidence
  module Rules
    class BenefitsRecipient < Rule
      include Evidence::RuleDsl

      key :income_benefits_0b
      group :income

      # NOTE: client/partner rule triggered when they statey
      # they are in receipt of a passporting benefit and the
      # DWP check returns a No or Undetermined result and they
      # state they have evidence of receipt of the benefit
      client do |crime_application|
        if crime_application.applicant
          conditions = [
            crime_application.applicant.has_benefit_evidence == 'yes',
            BenefitType.passporting.map(&:value).include?(crime_application.applicant.benefit_type&.to_sym),
            [nil, false].include?(crime_application.applicant.passporting_benefit)
          ]

          conditions.all?
        else
          false
        end
      end

      # TODO: Awaiting partner implementation
      partner do |_crime_application|
        false
      end
    end
  end
end
