module Summary
  module Sections
    class IncomeDetails < MeansBaseSection
      def show?
        false
      end
      def answers # rubocop:disable  Metrics/MethodLength
        [
          Components::ValueAnswer.new(
            :income_above_threshold, income.income_above_threshold,
            change_path: edit_steps_income_income_before_tax_path
          ),
          Components::ValueAnswer.new(
            :has_frozen_income_or_assets, income.has_frozen_income_or_assets,
            change_path: edit_steps_income_frozen_income_savings_assets_path
          ),
          Components::ValueAnswer.new(
            :client_owns_property, income.client_owns_property,
            change_path: edit_steps_income_client_owns_property_path
          ),
          Components::ValueAnswer.new(
            :has_savings, income.has_savings,
            change_path: edit_steps_income_has_savings_path
          ),
        ].select(&:show?)
      end
    end
  end
end
