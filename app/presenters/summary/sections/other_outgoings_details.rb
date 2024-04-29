module Summary
  module Sections
    class OtherOutgoingsDetails < Sections::BaseSection
      def show?
        outgoings.present? && super
      end

      # rubocop:disable Metrics/MethodLength
      def answers
        [
          Components::ValueAnswer.new(
            :income_tax_rate_above_threshold, outgoings.income_tax_rate_above_threshold,
            change_path: edit_steps_outgoings_income_tax_rate_path
          ),
          Components::ValueAnswer.new(
            :outgoings_more_than_income, outgoings.outgoings_more_than_income,
            change_path: edit_steps_outgoings_outgoings_more_than_income_path
          ),
          Components::FreeTextAnswer.new(
            :how_manage, outgoings.how_manage,
            change_path: edit_steps_outgoings_outgoings_more_than_income_path
          ),
        ].select(&:show?)
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end
