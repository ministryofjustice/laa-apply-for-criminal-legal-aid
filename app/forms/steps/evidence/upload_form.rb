module Steps
  module Evidence
    class UploadForm < Steps::BaseFormObject
      alias_attribute :current_document_bundle, :record

      private

      # :nocov:
      def persist!
        true
      end
      # :nocov:
    end
  end
end
