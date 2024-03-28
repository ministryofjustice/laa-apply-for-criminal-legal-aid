module Summary
  module Components
    class Offence < BaseRecord
      private

      def answers
        [
          OffenceTypeAndClassAnswer.new(
            :offence_type_and_class, offence
          ),
          OffenceDateAnswer.new(
            :offence_date, offence
          )
        ]
      end

      def name
        I18n.t('summary.sections.offence')
      end

      def summary_path
        edit_steps_case_charges_summary_path(id: crime_application_id)
      end

      def change_path
        edit_steps_case_charges_path(id: crime_application_id, charge_id: offence)
      end

      def remove_path
        confirm_destroy_steps_case_charges_path(id: crime_application_id, charge_id: offence)
      end

      def offence
        return record unless record.is_a? Charge

        @offence ||= ChargePresenter.new(record)
      end

      def crime_application_id
        offence.case.crime_application_id
      end
    end
  end
end
