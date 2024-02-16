module Steps
  module Capital
    class AddSavingForm < Steps::BaseFormObject
      attr_accessor :saving_type

      def choices
        SavingType.values
      end

      private

      def persist!
        crime_application.savings.create(saving_type:)
      end
    end
  end
end
