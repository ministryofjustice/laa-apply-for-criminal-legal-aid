module SubmissionSerializer
  module Definitions
    class Saving < Definitions::BaseDefinition
      def to_builder # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        Jbuilder.new do |json|
          json.saving_type saving_type
          json.provider_name provider_name
          json.sort_code sort_code
          json.account_number account_number
          json.account_balance account_balance_before_type_cast
          json.is_overdrawn is_overdrawn
          json.are_wages_paid_into_account are_wages_paid_into_account

          if include_partner_in_means_assessment?
            json.are_partners_wages_paid_into_account are_partners_wages_paid_into_account
          end
          json.ownership_type ownership_type
        end
      end
    end
  end
end
