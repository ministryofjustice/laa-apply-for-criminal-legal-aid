module Steps
  module Capital
    class OtherSavingTypeForm < SavingTypeForm
      private

      def persist!
        @saving = crime_application.savings.create!(saving_type:)
      end
    end
  end
end
