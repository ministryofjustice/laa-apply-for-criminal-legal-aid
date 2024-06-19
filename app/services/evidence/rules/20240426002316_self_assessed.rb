module Evidence
  module Rules
    class SelfAssessed < Rule
      include Evidence::RuleDsl

      key :income_p60_sa302_2
      group :income

      client do |crime_application|
        crime_application.outgoings&.income_tax_rate_above_threshold == 'yes' ||
          crime_application.income&.applicant_self_assessment_tax_bill == 'yes'
      end

      # TODO: awaiting partner_self_assessment_tax_bill
      partner do |crime_application|
        if MeansStatus.include_partner?(crime_application) && crime_application.outgoings
          (crime_application.outgoings.partner_income_tax_rate_above_threshold == 'yes') || false
        else
          false
        end
      end
    end
  end
end
