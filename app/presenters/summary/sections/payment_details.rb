module Summary
  module Sections
    class PaymentDetails < Sections::BaseSection
      def show?
        section.present? && super
      end

      def answers # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/PerceivedComplexity
        if payments.empty?
          [
            Components::ValueAnswer.new(
              question, 'none',
              change_path: edit_path
            )
          ].flatten.select(&:show?)
        else
          [
            # rubocop:disable Metrics/BlockLength
            ordered_payments.map do |payment_name, payment_details|
              change_path = "#{edit_path}#{anchor_prefix}#{payment_name.tr('_', '-')}-field"
              formatted_payment_name = payment_name + type_suffix

              if payment_details.nil?
                Components::FreeTextAnswer.new(
                  formatted_payment_name,
                  I18n.t('summary.does_not_get'),
                  change_path:
                )
              elsif payment_name == 'other'
                [Components::PaymentAnswer.new(
                  formatted_payment_name, payment_details,
                  show: true,
                  change_path: change_path
                ),
                 Components::FreeTextAnswer.new(
                   :other_payment_details, payment_details.metadata['details'],
                   show: payment_name == 'other',
                   change_path: change_path
                 )]
              else
                Components::PaymentAnswer.new(
                  formatted_payment_name, payment_details,
                  show: true,
                  change_path: change_path
                )
              end
            end
            # rubocop:enable Metrics/BlockLength
          ].flatten.select(&:show?)
        end
      end

      private

      # May be overridden in subclasses if the presence of another section is relevant
      def section
        @section ||= crime_application.income
      end

      def ordered_payments
        payment_types.index_with { |val| payment_of_type(val) }
      end

      def payment_of_type(type)
        payments.detect { |payment| payment.payment_type == type }
      end
    end
  end
end
