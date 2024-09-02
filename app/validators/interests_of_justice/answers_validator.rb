module InterestsOfJustice
  class AnswersValidator < BaseAnswerValidator
    def initialize(crime_application)
      record = crime_application.ioj || Ioj.new(case: crime_application.kase)

      super(record:, crime_application:)
    end

    def applicable?
      return false if crime_application.cifc?

      true
    end

    def validate
      return if complete?

      errors.add(:ioj, :incomplete)
      errors.add(:base, :incomplete_records)
    end

    def complete?
      crime_application.ioj_passported? || ioj_answers_complete?
    end

    private

    alias ioj record

    def ioj_answers_complete?
      return false unless ioj.present? && ioj.types.any?

      required_attributes = ioj.types.map { |type| "#{type}_justification" }
      ioj.values_at(*required_attributes).all?(&:present?)
    end
  end
end
