module Summary
  module Sections
    class OtherOutgoingsDetails < Sections::BaseSection
      include TypeOfMeansAssessment

      def show?
        outgoings.present? && super
      end

      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      def answers
        answers = [
          Components::ValueAnswer.new(
            :income_tax_rate_above_threshold, outgoings.income_tax_rate_above_threshold,
            change_path: edit_steps_outgoings_income_tax_rate_path
          ),
        ]

        if include_partner_in_means_assessment?
          answers.push(
            Components::ValueAnswer.new(
              :partner_income_tax_rate_above_threshold, outgoings.partner_income_tax_rate_above_threshold,
              change_path: edit_steps_outgoings_partner_income_tax_rate_path
            )
          )
        end

        answers.push(
          Components::ValueAnswer.new(
            :outgoings_more_than_income, outgoings.outgoings_more_than_income,
            change_path: edit_steps_outgoings_outgoings_more_than_income_path
          ),
          Components::FreeTextAnswer.new(
            :how_manage, outgoings.how_manage,
            change_path: edit_steps_outgoings_outgoings_more_than_income_path
          ),
        )

        answers.select(&:show?)
      end
      # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
    end
  end
end
