module Evidence
  module Rules
    class LostJobNotInCustody < Rule
      include Evidence::RuleDsl

      key :lost_job_34
      group :none

      client do |crime_application|
        required_fields = [
          crime_application.income,
          crime_application.income&.employment_status,
          crime_application.income&.ended_employment_within_three_months,
          crime_application.income&.lost_job_in_custody,
        ]

        if required_fields.all?
          conditions = [
            crime_application.income.employment_status == [EmploymentStatus::NOT_WORKING.to_s],
            crime_application.income.ended_employment_within_three_months == 'yes',
            crime_application.income.lost_job_in_custody == 'no',
          ]

          conditions.all?(true)
        else
          false
        end
      end
    end
  end
end
