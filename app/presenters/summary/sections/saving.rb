module Summary
  module Sections
    class Saving < Sections::BaseSection
      def show?
        saving.present? && super
      end

      def answers
        [
          Components::FreeTextAnswer.new(
            :provider_name, saving.provider_name,
            change_path: change_path(saving)
          ),

          Components::FreeTextAnswer.new(
            :sort_code, saving.sort_code,
            change_path: change_path(saving)
          ),

          Components::FreeTextAnswer.new(
            :account_number, saving.account_number,
            change_path: change_path(saving)
          ),
        ].flatten.compact.select(&:show?)
      end

      private

      def change_path(saving)
        edit_steps_capital_savings_path(saving_id: saving)
      end
    end
  end
end
