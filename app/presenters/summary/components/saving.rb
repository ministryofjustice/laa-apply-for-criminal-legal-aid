module Summary
  module Components
    class Saving < BaseRecord
      GROUP_BY = :saving_type

      alias saving record

      private

      def answers # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        answers = [
          Components::FreeTextAnswer.new(
            :provider_name, saving.provider_name, show: true
          ),
          Components::FreeTextAnswer.new(
            :sort_code, saving.sort_code, show: true
          ),
          Components::FreeTextAnswer.new(
            :account_number, saving.account_number, show: true
          ),
          Components::MoneyAnswer.new(
            :account_balance, saving.account_balance, show: true
          ),
          Components::ValueAnswer.new(
            :is_overdrawn, saving.is_overdrawn, show: true
          ),
          Components::ValueAnswer.new(
            :are_wages_paid_into_account,
            saving.are_wages_paid_into_account,
            show: true
          )
        ]

        if saving.are_partners_wages_paid_into_account.present?
          answers << Components::ValueAnswer.new(
            :are_partners_wages_paid_into_account,
            saving.are_partners_wages_paid_into_account,
          )
        end

        answers << Components::ValueAnswer.new(
          :saving_ownership_type, saving.ownership_type, show: true
        )

        answers.select(&:show?)
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

      delegate :crime_application, to: :record
    end
  end
end
