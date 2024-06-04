module Steps
  module Capital
    class OtherSavingTypeForm < Steps::BaseFormObject
      include TypeOfMeansAssessment
      include Steps::ApplicantOrPartner

      attr_accessor :saving_type
      attr_reader :saving

      validate :saving_type_selected

      def choices
        SavingType.values
      end

      private

      def persist!
        return true if saving_type == ''

        @saving = crime_application.savings.create!(saving_type:)
      end

      def saving_type_selected
        return if SavingType.values.map(&:to_s).include? saving_type.to_s

        errors.add(:saving_type, :blank, subject:)
      end
    end
  end
end
