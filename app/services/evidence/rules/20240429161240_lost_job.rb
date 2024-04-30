module Evidence
  module Rules
    class LostJob < Rule
      include Evidence::RuleDsl

      LOST_JOB_THRESHOLD = 3.months.freeze

      key :lost_job_33
      group :none

      client do |crime_application|
        required_fields = [
          crime_application.income,
          crime_application.income&.employment_status,
          crime_application.income&.ended_employment_within_three_months,
          crime_application.income&.lost_job_in_custody,
          crime_application.income&.date_job_lost,
        ]

        if required_fields.all?
          to = (crime_application.date_stamp || Time.zone.today).to_london_time
          from = crime_application.income.date_job_lost.to_london_time
          within_threshold = from > (to - LOST_JOB_THRESHOLD)

          conditions = [
            crime_application.income.employment_status == [EmploymentStatus::NOT_WORKING.to_s],
            crime_application.income.ended_employment_within_three_months == 'yes',
            crime_application.income.lost_job_in_custody == 'yes',
            within_threshold,
          ]

          conditions.all?(true)
        else
          false
        end
      end
    end
  end
end
=begin
"Clarification by chris:

- My client is not working
- Has your client ended employment in the last 3 months? = 'Yes'
- Did your client lose their job as a result of being in custody? = 'Yes'
- When did they lose their job? = Date is less than 3 months ago (from datestamp or today)"
=end
