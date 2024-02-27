module Summary
  module Sections
    class Savings < Sections::BaseSection
      def show?
        crime_application.savings.present? && super
      end

      def answers
        savings.map.with_index(1) do |saving, index|
          Components::SavingAnswer.new(
            :offence_details, SavingPresenter.new(saving),
            i18n_opts: { index: }
          )
        end.select(&:show?)

        # [
        #   savings.map do |saving|
        #     [
        #       Components::FreeTextAnswer.new(
        #         :provider_name, saving.provider_name,
        #         change_path: change_path(saving)
        #       ),
        #
        #       Components::FreeTextAnswer.new(
        #         :sort_code, saving.sort_code,
        #         change_path: change_path(saving)
        #       ),
        #
        #       Components::FreeTextAnswer.new(
        #         :account_number, saving.account_number,
        #         change_path: change_path(saving)
        #       ),
        #     ]
        #   end
        # ].flatten.compact.select(&:show?)
      end

      private

      def change_path(saving)
        edit_steps_capital_savings_path(saving_id: saving)
      end

      def savings
        @savings ||= crime_application.savings
      end
    end
  end
end
