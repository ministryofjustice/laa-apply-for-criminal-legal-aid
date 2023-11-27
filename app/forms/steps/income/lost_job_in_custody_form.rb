module Steps
  module Income
    class LostJobInCustodyForm < Steps::BaseFormObject
      include Steps::HasOneAssociation
      has_one_association :income

      attribute :lost_job_in_custody, :value_object, source: YesNoAnswer
      attribute :date_job_lost, :multiparam_date

      validates_inclusion_of :lost_job_in_custody, in: :choices

      validates :date_job_lost,
                multiparam_date: true,
                presence: true,
                if: -> { lost_job_in_custody? }

      validate :date_job_lost_over_three_months_ago, if: -> { lost_job_in_custody? }

      def choices
        YesNoAnswer.values
      end

      private

      def date_job_lost_over_three_months_ago
        return unless date_job_lost.is_a?(Date)

        errors.add(:date_job_lost, :over_three_months_ago) if date_job_lost.beginning_of_day < 3.months.ago
      end

      def persist!
        income.update(
          attributes.merge(attributes_to_reset)
        )
      end

      def attributes_to_reset
        {
          'date_job_lost' => (date_job_lost if lost_job_in_custody?)
        }
      end

      def lost_job_in_custody?
        lost_job_in_custody&.yes?
      end
    end
  end
end
