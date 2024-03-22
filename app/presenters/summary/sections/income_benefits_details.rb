module Summary
  module Sections
    class IncomeBenefitsDetails < Sections::BaseSection
      def show?
        income.present? && super
      end

      def answers # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
        if income_benefits.empty?
          [
            Components::ValueAnswer.new(
              :which_benefits, 'none',
              change_path: edit_steps_income_income_benefits_path
            )
          ].flatten.select(&:show?)
        else
          absent_payment_types = IncomeBenefitType.values.filter_map do |type|
            type.value.to_s unless type.value == :none
          end
          reported_payment_types = income_benefits.map(&:payment_type)
          absent_payment_types -= reported_payment_types

          [
            income_benefits.map do |payment|
              type = "steps-income-income-benefits-form-types-#{payment.payment_type.tr('_', '-')}-field"

              if payment.payment_type == 'other'
                [Components::PaymentAnswer.new(
                  "#{payment.payment_type}_benefit", payment,
                  show: true,
                  change_path: edit_steps_income_income_benefits_path(anchor: type)
                ),
                 Components::FreeTextAnswer.new(
                   :other_payment_details, payment.metadata['details'],
                   show: payment.payment_type == 'other',
                   change_path: edit_steps_income_income_benefits_path(anchor: type)
                 )]
              else
                Components::PaymentAnswer.new(
                  "#{payment.payment_type}_benefit", payment,
                  show: true,
                  change_path: edit_steps_income_income_benefits_path(anchor: type)
                )
              end
            end,
            absent_payment_types.map do |payment|
              type = "steps-income-income-benefits-form-types-#{payment.tr('_', '-')}-field"

              Components::FreeTextAnswer.new(
                "#{payment}_benefit",
                I18n.t('summary.does_not_get'),
                change_path: edit_steps_income_income_benefits_path(anchor: type)
              )
            end
          ].flatten.select(&:show?)
        end
      end

      private

      def income_benefits
        @income_benefits ||= crime_application.income_benefits
      end

      def income
        @income ||= crime_application.income
      end
    end
  end
end
