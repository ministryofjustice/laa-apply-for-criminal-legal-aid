module Summary
  module Sections
    class IncomePaymentsDetails < Sections::BaseSection
      def show?
        income.present? && super
      end

      def answers # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
        if income_payments.empty?
          [
            Components::ValueAnswer.new(
              :which_payments, 'none',
              change_path: edit_steps_income_income_payments_path
            )
          ].flatten.select(&:show?)
        else
          absent_payment_types = IncomePaymentType.values.filter_map do |type|
            type.value.to_s unless type.value == :none
          end
          reported_payment_types = income_payments.map(&:payment_type)
          absent_payment_types -= reported_payment_types

          [
            income_payments.map do |payment|
              type = "steps-income-income-payments-form-types-#{payment.payment_type.tr('_', '-')}-field"

              Components::PaymentAnswer.new(
                "#{payment.payment_type}_payment", payment,
                change_path: edit_steps_income_income_payments_path(anchor: type)
              )
            end,
            absent_payment_types.map do |payment|
              type = "steps-income-income-payments-form-types-#{payment.tr('_', '-')}-field"

              Components::FreeTextAnswer.new(
                "#{payment}_payment",
                I18n.t('summary.does_not_get'),
                change_path: edit_steps_income_income_payments_path(anchor: type)
              )
            end
          ].flatten.select(&:show?)
        end
      end

      private

      def income_payments
        @income_payments ||= crime_application.income_payments
      end

      def income
        @income ||= crime_application.income
      end
    end
  end
end
