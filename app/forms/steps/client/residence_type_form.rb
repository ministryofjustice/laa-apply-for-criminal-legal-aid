module Steps
  module Client
    class ResidenceTypeForm < Steps::BaseFormObject
      include Steps::HasOneAssociation
      has_one_association :applicant

      attribute :residence_type, :value_object, source: ResidenceType
      attribute :relationship_to_someone_else, :string

      validates :residence_type,
                inclusion: { in: :choices }

      validates :relationship_to_someone_else,
                presence: true,
                if: -> { someone_else? }

      def choices
        ResidenceType.values
      end

      private

      def changed?
        # The attribute is a `value_object`, overriding generic `#changed?`
        !applicant.residence_type.eql?(residence_type.to_s) ||
          !applicant.relationship_to_someone_else.eql?(relationship_to_someone_else)
      end

      def persist!
        return true unless changed?

        applicant.update(attributes.merge(attributes_to_reset))
      end

      def attributes_to_reset
        {
          'relationship_to_someone_else' => (relationship_to_someone_else if someone_else?)
        }
      end

      def someone_else?
        residence_type&.someone_else?
      end
    end
  end
end
