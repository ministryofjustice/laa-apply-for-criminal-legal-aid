module Steps
  module Case
    class UrnForm < Steps::BaseFormObject
      include Steps::HasOneAssociation
      has_one_association :case

      URN_REGEXP = /\A[0-9]{2}[A-Z]{2}[0-9]{7}\z/

      attribute :urn, :string

      validates :urn, format: { with: URN_REGEXP }, allow_blank: true

      def urn=(str)
        super(str.upcase.delete(' ')) if str
      end

      private

      def persist!
        kase.update(
          attributes
        )
      end
    end
  end
end
