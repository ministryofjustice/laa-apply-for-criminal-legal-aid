module Steps
  module Client
    class AppealDetailsForm < Steps::BaseFormObject
      include Steps::HasOneAssociation

      has_one_association :case

      attribute :appeal_lodged_date, :multiparam_date
      attribute :appeal_original_app_submitted, :value_object, source: YesNoAnswer

      validates :appeal_lodged_date,
                presence: true, multiparam_date: true

      validates_inclusion_of :appeal_original_app_submitted,
                             in: :yes_no_choices,
                             presence: true

      def yes_no_choices
        YesNoAnswer.values
      end

      private

      def persist!
        self.case.update(
          attributes
        )
      end
    end
  end
end
