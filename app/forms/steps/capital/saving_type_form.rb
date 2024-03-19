module Steps
  module Capital
    class SavingTypeForm < Steps::BaseFormObject
      attr_accessor :saving_type

      validates :saving_type, presence: true

      attr_reader :saving

      def choices
        SavingType.values
      end

      private

      def persist!
        return true if saving_type == 'none'

        @saving = incomplete_saving_for_type || crime_application.savings.create!(saving_type:)
      end

      def incomplete_saving_for_type
        return nil unless saving_type

        crime_application.savings.where(saving_type:).reject(&:complete?).first
      end
    end
  end
end
