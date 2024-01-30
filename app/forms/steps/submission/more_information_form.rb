module Steps
  module Submission
    class MoreInformationForm < Steps::BaseFormObject
      attribute :additional_information, :string

      validates :additional_information, presence: true,
        unless: -> { more_information_not_needed? }

      def persist!
        self.additional_information = nil if more_information_not_needed?

        crime_application.update(additional_information:)
      end

      def choices
        YesNoAnswer.values
      end

      def need_more_information
        return @need_more_information unless @need_more_information.nil?

        YesNoAnswer::YES if crime_application.additional_information.present?
      end

      def need_more_information=(attr)
        @need_more_information = YesNoAnswer.new(attr)
      end

      private

      def more_information_not_needed?
        need_more_information == YesNoAnswer::NO
      end
    end
  end
end
