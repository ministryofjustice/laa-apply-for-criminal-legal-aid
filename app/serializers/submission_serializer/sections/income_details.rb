module SubmissionSerializer
  module Sections
    class IncomeDetails < Sections::BaseSection
      def to_builder # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        Jbuilder.new do |json|
          json.income_above_threshold income.income_above_threshold
          json.employment_type income.employment_status
          json.employments Definitions::Employment.generate(crime_application.employments)
          json.ended_employment_within_three_months income.ended_employment_within_three_months
          json.lost_job_in_custody income.lost_job_in_custody
          json.date_job_lost income.date_job_lost
          json.has_frozen_income_or_assets income.has_frozen_income_or_assets
          json.client_owns_property income.client_owns_property
          json.has_savings income.has_savings
          json.manage_without_income income.manage_without_income
          json.manage_other_details income.manage_other_details
          json.client_has_dependants income.client_has_dependants
          json.dependants Definitions::Dependant.generate(income.dependants.with_ages)
          json.income_payments Definitions::Payment.generate(income.income_payments)
          json.income_benefits Definitions::Payment.generate(income.income_benefits)
          json.has_no_income_payments income.has_no_income_payments
          json.has_no_income_benefits income.has_no_income_benefits
          json.applicant_other_work_benefit_received income.applicant_other_work_benefit_received
        end
      end
    end
  end
end
