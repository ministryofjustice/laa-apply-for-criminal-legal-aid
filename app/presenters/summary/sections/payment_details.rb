module Summary
  module Sections
    class PaymentDetails < Sections::BaseSection
      def show?
        payments.present?
      end

      def answers # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/PerceivedComplexity
        if no_payments?
          [
            Components::ValueAnswer.new(
              question, 'none',
              change_path: edit_path
            )
          ].flatten.select(&:show?)
        else
          [
            ordered_payments.map do |payment_name, payment_details|
              change_path = "#{edit_path}#{anchor_prefix}#{payment_name.tr('_', '-')}-field"
              formatted_payment_name = payment_name + type_suffix

              if payment_details.nil?
                Components::FreeTextAnswer.new(
                  formatted_payment_name,
                  I18n.t('summary.dictionary.YESNO.no'),
                  change_path:
                )
              elsif requires_extra_details(payment_name)
                payment_answer_with_details_components(formatted_payment_name, payment_details, change_path)
              else
                payment_answer_component(formatted_payment_name, payment_details, change_path)
              end
            end
          ].flatten.select(&:show?)
        end
      end

      private

      # :nocov:
      def no_payments?
        raise 'must be implemented in subclasses'
      end
      # :nocov:

      def ordered_payments
        payment_types.index_with { |val| payment_of_type(val) }
      end

      def payment_of_type(type)
        payments.detect { |payment| payment.payment_type == type }
      end

      def payment_answer_component(name, details, change_path)
        Components::PaymentAnswer.new(
          name, details,
          show: true,
          change_path: change_path
        )
      end

      def payment_answer_with_details_components(name, details, change_path)
        answer = payment_answer_component(name, details, change_path)
        key = name == 'legal_aid_contribution_outgoing' ? 'case_reference' : 'details'

        details_component = Components::FreeTextAnswer.new(
          :"#{name}_details", details.metadata[key],
          show: true,
          change_path: change_path
        )
        [answer, details_component]
      end

      def requires_extra_details(name)
        %w[other legal_aid_contribution].include?(name)
      end

      def subject_type
        SubjectType.new(:applicant)
      end
    end
  end
end
