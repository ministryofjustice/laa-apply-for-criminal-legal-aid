module PassportingBenefitCheck
  class AnswersValidator
    include TypeOfMeansAssessment

    def initialize(record)
      @record = record
    end

    attr_reader :record

    delegate :errors, :applicant, :crime_application, to: :record

    def validate
      return true if Passporting::MeansPassporter.new(crime_application).call
      return true if applicant.benefit_type == 'none'
      return true if evidence_of_passporting_means_forthcoming?

      errors.add :base, :incomplete_records unless errors.empty?
    end

    alias crime_application record
  end
end
