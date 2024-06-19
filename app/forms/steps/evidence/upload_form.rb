module Steps
  module Evidence
    class UploadForm < Steps::BaseFormObject
      include TypeOfMeansAssessment
      include ApplicantAndPartner

      delegate :documents, to: :crime_application

      def prompt
        @prompt ||= ::Evidence::Prompt.new(crime_application).run!(ignore_exempt: false)
      end

      private

      # :nocov:
      def persist!
        true
      end
      # :nocov:
    end
  end
end
