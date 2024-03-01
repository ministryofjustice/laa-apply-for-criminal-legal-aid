module SubmissionSerializer
  module Sections
    class MeansDetails < Sections::BaseSection
      def to_builder # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        Jbuilder.new do |json| # rubocop:disable Metrics/BlockLength
          next if income.blank?

          json.means_details do # rubocop:disable Metrics/BlockLength
            json.income_details do
              json.income_above_threshold income.income_above_threshold
              json.employment_type income.employment_status
              json.ended_employment_within_three_months income.ended_employment_within_three_months
              json.lost_job_in_custody income.lost_job_in_custody
              json.date_job_lost income.date_job_lost
              json.has_frozen_income_or_assets income.has_frozen_income_or_assets
              json.client_owns_property income.client_owns_property
              json.has_savings income.has_savings
              json.manage_without_income income.manage_without_income
              json.manage_other_details income.manage_other_details
              json.dependants Definitions::Dependant.generate(crime_application.dependants.with_ages)
              json.income_payments Definitions::Payment.generate(crime_application.income_payments)
              json.income_benefits Definitions::Payment.generate(crime_application.income_benefits)
            end

            json.outgoings_details do
              json.outgoings Definitions::Payment.generate(crime_application.outgoings_payments)

              json.housing_payment_type outgoings&.housing_payment_type
              json.income_tax_rate_above_threshold outgoings&.income_tax_rate_above_threshold
              json.outgoings_more_than_income outgoings&.outgoings_more_than_income
              json.how_manage outgoings&.how_manage
            end

            if capital
              json.capital_details do
                json.has_premium_bonds capital.has_premium_bonds
                json.premium_bonds_total_value capital.premium_bonds_total_value_before_type_cast
                json.premium_bonds_holder_number capital.premium_bonds_holder_number
                json.savings Definitions::Saving.generate(capital.savings)
              end
            end
          end
        end
      end

      private

      def income
        @income ||= crime_application.income
      end

      def outgoings
        @outgoings ||= crime_application.outgoings
      end

      def capital
        @capital ||= crime_application.capital
      end
    end
  end
end
