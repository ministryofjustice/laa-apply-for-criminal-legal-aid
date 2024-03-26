module Summary
  module Sections
    class OtherCapitalDetails < Sections::BaseSection
      def show?
        capital.present? && super
      end

      def answers
        [
          Components::ValueAnswer.new(
            :has_frozen_income_or_assets, capital.has_frozen_income_or_assets,
            change_path: edit_steps_capital_frozen_income_savings_assets_capital_path
          ),
        ].select(&:show?)

        # [
        #   Components::ValueAnswer.new(
        #     :has_no_other_assets, capital.has_no_other_assets,
        #     change_path: edit_steps_capital_answers_path
        #   ),
        # ].select(&:show?)
      end

      private

      def capital
        @capital ||= crime_application.capital
      end
    end
  end
end
