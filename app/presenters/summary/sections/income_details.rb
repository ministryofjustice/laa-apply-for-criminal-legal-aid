module Summary
  module Sections
    class IncomeDetails < Sections::BaseSection
      include TypeOfMeansAssessment

      def show?
        income.present? && super
      end

      def answers # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        answers = []
        answers << if include_partner_in_means_assessment?
                     Components::ValueAnswer.new(
                       :joint_income_above_threshold, income.income_above_threshold,
                       change_path: edit_steps_income_income_before_tax_path
                     )
                   else
                     Components::ValueAnswer.new(
                       :income_above_threshold, income.income_above_threshold,
                       change_path: edit_steps_income_income_before_tax_path
                     )
                   end

        answers << [
          Components::ValueAnswer.new(
            :has_frozen_income_or_assets, income.has_frozen_income_or_assets,
            change_path: edit_steps_income_frozen_income_savings_assets_path
          ),
          Components::ValueAnswer.new(
            :client_owns_property, income.client_owns_property,
            change_path: edit_steps_income_client_owns_property_path,
            subject_type: property_ownership_type
          ),
          Components::ValueAnswer.new(
            :has_savings, income.has_savings,
            change_path: edit_steps_income_has_savings_path
          ),
        ]

        answers.flatten.select(&:show?)
      end

      private

      def property_ownership_type
        return unless include_partner_in_means_assessment?

        SubjectType.new(:applicant_or_partner)
      end
    end
  end
end
