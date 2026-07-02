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
          Components::ValueAnswer.new(
            :frozen_income_or_assets_subject, capital.frozen_income_or_assets_subject,
            change_path: edit_steps_capital_frozen_income_or_assets_subject_path
          ),
        ].select(&:show?)
      end
    end
  end
end
