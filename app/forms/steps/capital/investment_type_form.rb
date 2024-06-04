module Steps
  module Capital
    class InvestmentTypeForm < Steps::BaseFormObject
      include Steps::HasOneAssociation
      include TypeOfMeansAssessment
      include Steps::ApplicantOrPartner

      has_one_association :capital

      attr_writer :investment_type
      attr_reader :investment

      validate :investment_type_selected
      validates :has_no_investments, inclusion: { in: ['yes', nil] }

      def choices
        InvestmentType.values
      end

      def investment_type
        return @investment_type if @investment_type

        'none' if capital.has_no_investments == 'yes'
      end

      def has_no_investments
        'yes' if investment_type == 'none'
      end

      private

      def persist!
        capital.update(has_no_investments:)

        return true if investment_type == 'none'

        @investment = incomplete_investment_for_type || crime_application.investments.create!(investment_type:)
      end

      def incomplete_investment_for_type
        return nil unless investment_type

        crime_application.investments.where(investment_type:).reject(&:complete?).first
      end

      def investment_type_selected
        return if (InvestmentType.values.map(&:to_s) << 'none').include? investment_type.to_s

        errors.add(:investment_type, :blank, subject:)
      end
    end
  end
end
