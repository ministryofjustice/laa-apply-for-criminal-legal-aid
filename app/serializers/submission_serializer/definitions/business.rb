module SubmissionSerializer
  module Definitions
    class Business < Definitions::BaseDefinition
      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      def to_builder
        raise 'Do we need this'
        Jbuilder.new do |json|
          json.ownership_type ownership_type
          json.business_type business_type
          json.trading_name trading_name
          json.address address
          json.description description
          json.trading_start_date trading_start_date
          json.has_additional_owners has_additional_owners
          json.additional_owners additional_owners
          json.has_employees has_employees
          json.number_of_employees number_of_employees
          json.salary salary
          json.total_income_share_sales total_income_share_sales
          json.percentage_profit_share percentage_profit_share
          json.turnover turnover
          json.drawings drawings
          json.profit profit
        end
      end
      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
    end
  end
end
