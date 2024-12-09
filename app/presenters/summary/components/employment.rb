module Summary
  module Components
    class Employment < BaseRecord
      include HasDynamicSubject

      alias employment record

      private

      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      def answers
        attributes =
          [
            Components::FreeTextAnswer.new(
              'employment.employer_name', employment.employer_name
            ),
            Components::FreeTextAnswer.new(
              'employment.address', full_address(employment.address)
            ),
            Components::FreeTextAnswer.new(
              'employment.job_title', employment.job_title
            )
          ]

        attributes << if employment.amount.present?
                        Components::PaymentAnswer.new(
                          'employment.salary_or_wage', employment
                        )
                      else
                        Components::FreeTextAnswer.new(
                          'employment.salary_or_wage', employment.amount
                        )
                      end

        if employment.deductions.present?
          employment.deductions.each do |deduction|
            attributes << Components::PaymentAnswer.new(
              "deduction.#{deduction.deduction_type}", deduction
            )
            next unless deduction.other?

            attributes << Components::FreeTextAnswer.new(
              "deduction.#{deduction.deduction_type}.details", deduction.details
            )
          end
        else
          attributes << Components::ValueAnswer.new('employment.has_no_deductions', employment.has_no_deductions)
        end

        attributes
      end
      # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

      def name
        I18n.t('summary.sections.employment')
      end

      def subject_type
        OWNERSHIP_TYPE_MAPPING[employment.ownership_type]
      end

      def full_address(address)
        return unless address

        address.values_at(*Address::ADDRESS_ATTRIBUTES.map(&:to_s)).compact_blank.join("\r\n")
      end

      def change_path
        send :"edit_steps_income_#{subject_type}_employer_details_path", employment_id: employment.id
      end

      def summary_path
        send :"edit_steps_income_#{subject_type}_employments_summary_path", employment_id: employment.id
      end

      def remove_path
        send :"confirm_destroy_steps_income_#{subject_type}_employments_path", employment_id: employment.id
      end
    end
  end
end
