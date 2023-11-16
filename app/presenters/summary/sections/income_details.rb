module Summary
  module Sections
    class IncomeDetails < Sections::BaseSection
      def name
        :income_details
      end

      def show?
        income_details.present? && super
      end

      def answers
        [
          Components::ValueAnswer.new(
            :income_above_threshold, income_details.income_above_threshold,
            change_path: edit_steps_income_income_before_tax_path
          ),
          Components::ValueAnswer.new(
            :has_frozen_income_or_assets, income_details.has_frozen_income_or_assets,
            change_path:  edit_steps_income_frozen_income_savings_assets_path
          ),
          Components::ValueAnswer.new(
            :client_owns_property, income_details.client_owns_property,
            change_path: edit_steps_income_client_owns_property_path
          ),
        ].select(&:show?)
      end

      private

      def income_details
        @income_details ||= crime_application.income_details
      end
    end
  end
end
