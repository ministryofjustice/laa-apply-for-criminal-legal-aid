module Steps
  module Evidence
    class UploadForm < Steps::BaseFormObject
      include TypeOfMeansAssessment
      include ApplicantAndPartner

      delegate :documents, :evidence_prompts, to: :crime_application

      validate do
        validator.validate
      end

      def prompt
        @prompt ||= ::Evidence::Prompt.new(crime_application).run!(ignore_exempt: false)
      end

      private

      def validator
        @validator ||= ::SupportingEvidence::AnswersValidator.new(
          record: self, crime_application: crime_application
        )
      end

      # :nocov:
      def persist!
        true
      end
      # :nocov:
    end
  end
end
