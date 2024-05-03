module Steps
  module Submission
    class MoreInformationForm < Steps::BaseFormObject
      attribute :additional_information_required, :value_object, source: YesNoAnswer
      attribute :additional_information, :string

      validates :additional_information_required, inclusion: { in: :choices }

      validates :additional_information, presence: true,
                if: -> { additional_information_needed? }

      def persist!
        crime_application.update(attributes)
      end

      def choices
        YesNoAnswer.values
      end

      private

      def additional_information_needed?
        additional_information_required == YesNoAnswer::YES
      end

      def before_save
        self.additional_information = nil unless additional_information_needed?
      end
    end
  end
end
