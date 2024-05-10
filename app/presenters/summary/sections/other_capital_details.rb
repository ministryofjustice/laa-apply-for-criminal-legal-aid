module Summary
  module Sections
    class OtherCapitalDetails < Sections::MeansBaseSection
      def answers
        [
          Components::ValueAnswer.new(
            :has_frozen_income_or_assets, capital.has_frozen_income_or_assets,
            change_path: edit_steps_capital_frozen_income_savings_assets_capital_path
          )
        ].select(&:show?)
      end
    end
  end
end
