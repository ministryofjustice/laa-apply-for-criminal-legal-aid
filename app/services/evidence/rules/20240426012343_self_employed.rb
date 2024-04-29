module Evidence
  module Rules
    class SelfEmployed < Rule
      include Evidence::RuleDsl

      key :income_selfemployed_3
      group :income

      client do |crime_application|
        self_employed_status = [
          EmploymentStatus::SELF_EMPLOYED.to_s,
          EmploymentStatus::BUSINESS_PARTNERSHIP.to_s,
          EmploymentStatus::SHAREHOLDER.to_s,
        ]

        self_employed_status.intersect?(
          Array.wrap(crime_application.income&.employment_status)
        )
      end

      # TODO: Awaiting partner implementation
      partner do |_crime_application|
        false
      end
    end
  end
end
