module Adapters
  module Structs
    class SupportingEvidence < BaseStructAdapter
      # [
      #   {
      #     "s3_object_key": "12345/xyz",
      #     "filename": "test.pdf"
      #   },
      #   ...
      # ]

      def document_bundle
        pp struct
        super.map { |struct| Document.new(struct.attributes) }
        DocumentBundle.new(documents:)
      end

      # def initialize(collection)
      #   document = Document.new
      #
      #   document.attributes = {}.tap do |attrs|
      #     collection.each do |_item|
      #       attrs.merge
      #     end
      #   end
      #
      #   # For re-hydration and summary page, we don't really want
      #   # a "blank" instance of the IoJ, so we `nil` in those cases
      #   # ioj = nil if ioj.types.empty?
      #
      #   super(document)
      # end

      def serializable_hash(options = {})
        super(
          options.merge(
            methods: []
          )
        )
      end
    end
  end
end
