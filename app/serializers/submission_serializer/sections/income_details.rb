module SubmissionSerializer
  module Sections
    class IncomeDetails < Sections::BaseSection
      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/BlockLength
      def to_builder
        Jbuilder.new do |json|
          json.income_above_threshold income.income_above_threshold
          json.employment_type income.employment_status
          json.employments Definitions::Employment.generate(income.employments)
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
          json.applicant_self_assessment_tax_bill income.applicant_self_assessment_tax_bill
          json.applicant_self_assessment_tax_bill_amount income.applicant_self_assessment_tax_bill_amount_before_type_cast # rubocop:disable Layout/LineLength
          json.applicant_self_assessment_tax_bill_frequency income.applicant_self_assessment_tax_bill_frequency

          if include_partner_in_means_assessment?
            json.partner_has_no_income_payments income.partner_has_no_income_payments
            json.partner_has_no_income_benefits income.partner_has_no_income_benefits
            json.partner_employment_type income.partner_employment_status
            json.partner_other_work_benefit_received income.partner_other_work_benefit_received
            json.partner_self_assessment_tax_bill income.partner_self_assessment_tax_bill
            json.partner_self_assessment_tax_bill_amount income.partner_self_assessment_tax_bill_amount_before_type_cast
            json.partner_self_assessment_tax_bill_frequency income.partner_self_assessment_tax_bill_frequency
          end

          # Attribute required  CAA (crime application adaptor)
          annualized_employment_payments = EmploymentIncomePaymentsCalculator.annualized_payments(crime_application)
          json.employment_income_payments annualized_employment_payments do |attachment|
            json.amount attachment[:amount]
            json.income_tax attachment[:income_tax]
            json.national_insurance attachment[:national_insurance]
            json.frequency attachment[:frequency]
            json.ownership_type attachment[:ownership_type]
          end

          json.businesses income.businesses
        end
      end
      # rubocop:enable Metrics/MethodLength, Metrics/AbcSize, Metrics/BlockLength
    end
  end
end
