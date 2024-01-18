module Steps
  module Evidence
    class AdditionalInformationForm < Steps::BaseFormObject
      attribute :additional_information, :string

      validates :additional_information, presence: true,
        unless: -> { additional_information_not_needed? }

      def persist!
        self.additional_information = nil if additional_information_not_needed?

        crime_application.update(additional_information:)
      end

      def choices
        YesNoAnswer.values
      end

      def add_additional_information
        return @add_additional_information unless @add_additional_information.nil?

        YesNoAnswer::YES if crime_application.additional_information.present?
      end

      def add_additional_information=(attr)
        @add_additional_information = YesNoAnswer.new(attr)
      end

      private

      def additional_information_not_needed?
        add_additional_information == YesNoAnswer::NO
      end
    end
  end
end
