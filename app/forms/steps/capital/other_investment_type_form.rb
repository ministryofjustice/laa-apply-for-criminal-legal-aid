module Steps
  module Capital
    class OtherInvestmentTypeForm < Steps::BaseFormObject
      include TypeOfMeansAssessment
      include Steps::ApplicantOrPartner

      attr_accessor :investment_type
      attr_reader :investment

      validate :investment_type_selected

      def choices
        InvestmentType.values
      end

      private

      def persist!
        return true if investment_type == ''

        @investment = crime_application.investments.create!(investment_type:)
      end

      def investment_type_selected
        return if (InvestmentType.values.map(&:to_s) << 'none').include? investment_type.to_s

        errors.add(:investment_type, :blank, subject:)
      end
    end
  end
end
