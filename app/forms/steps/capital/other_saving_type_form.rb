module Steps
  module Capital
    class OtherSavingTypeForm < Steps::BaseFormObject
      attr_accessor :saving_type
      attr_reader :saving

      validates :saving_type, presence: true
      validates :saving_type, inclusion: { in: SavingType.values.map(&:to_s) }

      def choices
        SavingType.values
      end

      private

      def persist!
        return true if saving_type == ''

        @saving = crime_application.savings.create!(saving_type:)
      end
    end
  end
end
