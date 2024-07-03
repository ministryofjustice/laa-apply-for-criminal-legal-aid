module Evidence
  module Rules
    class BenefitsInKind < Rule
      include Evidence::RuleDsl

      key :income_noncash_benefit_4
      group :income

      client do |crime_application|
        if crime_application.income
          crime_application.income.applicant_other_work_benefit_received == 'yes'
        else
          false
        end
      end

      partner do |crime_application|
        if crime_application.income
          crime_application.income.partner_other_work_benefit_received == 'yes'
        else
          false
        end
      end
    end
  end
end
