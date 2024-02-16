module Steps
  module Capital
    class AddSavingForm < Steps::BaseFormObject
      attr_accessor :saving_type

      validates :saving_type, presence: true

      def choices
        SavingType.values
      end

      private

      def persist!
        # TODO: If none, go to next step
        # If type selected, build new savings form
      end
    end
  end
end
