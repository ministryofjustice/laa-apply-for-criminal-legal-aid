module Steps
  module Income
    class UsualPropertyDetailsForm < Steps::BaseFormObject
      include UsualPropertyDetails
      include TypeOfMeansAssessment
      include ApplicantOrPartner

      def choices
        UsualPropertyDetailsIncomeAnswer.values
      end

      def action
        return if @action.nil?

        UsualPropertyDetailsIncomeAnswer.new(@action)
      end
    end
  end
end
