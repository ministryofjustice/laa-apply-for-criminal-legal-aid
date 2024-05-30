module Summary
  module Components
    class Saving < BaseRecord
      alias saving record

      private

      def answers # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        [
          Components::FreeTextAnswer.new(
            :provider_name, saving.provider_name
          ),
          Components::FreeTextAnswer.new(
            :sort_code, saving.sort_code
          ),
          Components::FreeTextAnswer.new(
            :account_number, saving.account_number
          ),
          Components::MoneyAnswer.new(
            :account_balance, saving.account_balance
          ),
          Components::ValueAnswer.new(
            :is_overdrawn, saving.is_overdrawn
          ),
          Components::ValueAnswer.new(
            :are_wages_paid_into_account, saving.are_wages_paid_into_account
          ),
          Components::ValueAnswer.new(
            :saving_ownership_type, saving.ownership_type
          )
        ]
      end

      def name
        I18n.t(saving.saving_type, scope: [:summary, :sections, :saving])
      end

      def change_path
        edit_steps_capital_savings_path(saving_id: record.id)
      end

      def summary_path
        edit_steps_capital_savings_summary_path
      end

      def remove_path
        confirm_destroy_steps_capital_savings_path(saving_id: record.id)
      end
    end
  end
end
