module Summary
  module Components
    class Employment < BaseRecord # rubocop:disable Metrics/ClassLength
      alias employment record

      private

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
            ),
            Components::PaymentAnswer.new(
              'employment.salary_or_wage', employment
            )
          ]

        employment.deductions.each do |deduction|
          attributes << Components::PaymentAnswer.new(
            "deduction.#{deduction.deduction_type}", deduction
          )
          next unless deduction.other?

          attributes << Components::FreeTextAnswer.new(
            "deduction.#{deduction.deduction_type}.details", deduction.details
          )
        end

        attributes
      end

      def full_address(address)
        return unless address

        address.values_at(*Address::ADDRESS_ATTRIBUTES.map(&:to_s)).compact_blank.join("\r\n")
      end

      def change_path
        edit_steps_income_client_employer_details_path(employment_id: employment.id)
      end

      def summary_path
        edit_steps_income_client_employments_summary_path(employment_id: employment.id)
      end

      def remove_path
        confirm_destroy_steps_income_client_employments_path(employment_id: employment.id)
      end
    end
  end
end
