module Steps
  module Income
    class EmploymentStatusForm < Steps::BaseFormObject
      include Steps::HasOneAssociation
      has_one_association :applicant

      attribute :employment_status, :value_object, source: EmploymentStatus
      attribute :ended_employment_within_three_months, :value_object, source: YesNoAnswer

      validates_inclusion_of :employment_status, in: :choices

      validates_inclusion_of :ended_employment_within_three_months,
                             in: :yes_no_choices,
                             presence: true,
                             if: -> { not_working? }

      def choices
        EmploymentStatus.values
      end

      def yes_no_choices
        YesNoAnswer.values
      end

      private

      def persist!
        applicant.update(
          attributes.merge(attributes_to_reset)
        )
      end

      def attributes_to_reset
        {
          'ended_employment_within_three_months' => (ended_employment_within_three_months if not_working?)
        }
      end

      def not_working?
        employment_status&.not_working?
      end
    end
  end
end
