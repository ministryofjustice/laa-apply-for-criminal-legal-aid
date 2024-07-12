module SubmissionSerializer
  module Definitions
    class Business < Definitions::BaseDefinition
      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      def to_builder
        Jbuilder.new do |json|
          json.ownership_type ownership_type
          json.business_type business_type
          json.trading_name trading_name
          json.address address
          json.description description
          json.trading_start_date trading_start_date.as_json
          json.has_additional_owners has_additional_owners
          json.additional_owners additional_owners
          json.has_employees has_employees
          json.number_of_employees number_of_employees
          json.turnover turnover.as_json
          json.drawings drawings.as_json
          json.profit profit.as_json
          json.salary salary.as_json unless payment_blank?(salary)
          json.total_income_share_sales total_income_share_sales.as_json unless payment_blank?(total_income_share_sales)
          json.percentage_profit_share percentage_profit_share&.to_f
        end
      end
      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

      def payment_blank?(payment)
        payment&.amount.blank? || payment&.frequency.blank?
      end
    end
  end
end
