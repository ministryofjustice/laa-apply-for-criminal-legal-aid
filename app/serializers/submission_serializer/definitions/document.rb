module SubmissionSerializer
  module Definitions
    class Document < Definitions::BaseDefinition
      def to_builder
        Jbuilder.new do |json|
          json.s3_object_key s3_object_key
          json.filename filename
          json.content_type content_type
          json.file_size file_size
        end
      end
    end
  end
end
