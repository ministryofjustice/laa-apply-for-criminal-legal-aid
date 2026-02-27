module Steps
  module Case
    class UrnForm < Steps::BaseFormObject
      include Steps::HasOneAssociation

      has_one_association :case

      URN_REGEXP = /\A[A-Z0-9]{6,20}\z/

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
