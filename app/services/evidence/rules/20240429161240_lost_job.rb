module Evidence
  module Rules
    class LostJob < Rule
      include Evidence::RuleDsl

      REMANDED_MONTHS_THRESHOLD = 3

      key :lost_job_33
      group :none

      client do |crime_application|
        required_fields = [
          crime_application.income,
          crime_application.case,
          crime_application.case&.date_client_remanded,
          crime_application.income&.employment_status,
          crime_application.income&.ended_employment_within_three_months,
        ]

        if required_fields.all?
          from = (crime_application.date_stamp || Time.zone.today).to_time
          to = crime_application.case.date_client_remanded.to_time
          from, to = to, from if to > from
          parts = ActiveSupport::Duration.build((from - to).to_i).parts.slice(:months, :days)

          within_threshold =
            parts[:months].nil? || # Assume must be 0 months
            parts[:months] < REMANDED_MONTHS_THRESHOLD ||
            (parts[:months] == REMANDED_MONTHS_THRESHOLD && (parts[:days] || 0) <= 0)

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
