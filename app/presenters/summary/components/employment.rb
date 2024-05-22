module Summary
  module Components
    class Employment < BaseRecord # rubocop:disable Metrics/ClassLength
      alias employment record

      private

      def answers
        attributes =
          [
            Components::FreeTextAnswer.new(
              :employer_name, employment.employer_name
            ),
            Components::FreeTextAnswer.new(
              :address, full_address(employment.address)
            ),
            Components::FreeTextAnswer.new(
              :job_title, employment.job_title
            )
          ]


        if employment.income_payment.present?
          attributes << Components::MoneyAnswer.new(
          :amount, employment.income_payment.amount
        )
          attributes << Components::FreeTextAnswer.new(
            :frequency, employment.income_payment.frequency.to_s
          )
          attributes << Components::PaymentAnswer.new(
            :frequency, employment.income_payment
          )
        end


        employment.deductions.each do |deduction|
          attributes << Components::FreeTextAnswer.new(
            :deduction_type, deduction.deduction_type
          )
          attributes << Components::MoneyAnswer.new(
            :amount, deduction.amount
          )
          attributes << Components::FreeTextAnswer.new(
            :frequency, deduction.frequency
          )
          attributes << Components::FreeTextAnswer.new(
            :details, deduction.details
          )
        end

        attributes
      end

      def full_address(address)
        return unless address

        address.values_at(*Address::ADDRESS_ATTRIBUTES.map(&:to_s)).compact_blank.join("\r\n")
      end

      def change_path
        edit_steps_income_client_employer_details_path(id: record.crime_application_id, employment_id: employment.id)
      end

      def summary_path
        edit_steps_income_client_employments_summary_path(id: record.crime_application_id, employment_id: employment.id)
      end

      def remove_path
        confirm_destroy_steps_income_client_employments_path(id: record.crime_application_id, employment_id: employment.id)
      end
    end
  end
end
