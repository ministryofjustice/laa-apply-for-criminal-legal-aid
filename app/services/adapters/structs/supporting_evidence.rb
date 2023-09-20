module Adapters
  module Structs
    class SupportingEvidence < BaseStructAdapter
      # [
      #   {
      #     "s3_object_key": "123/abcdef1234",
      #     "filename": "test.pdf"
      #   },
      #   ...
      # ]

      def supporting_evidence
        super.map { |struct| Document.new(struct.attributes) }
      end

      def serializable_hash(options = {})
        super(
          options.merge(
            methods: [:supporting_evidence]
          )
        )
      end
    end
  end
end
