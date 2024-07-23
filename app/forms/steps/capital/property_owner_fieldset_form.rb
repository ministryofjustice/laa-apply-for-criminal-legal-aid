module Steps
  module Capital
    class PropertyOwnerFieldsetForm < Steps::BaseFormObject
      attribute :_destroy, :boolean, default: false
      attribute :id, :string
      attribute :name, :string
      attribute :relationship, :string
      attribute :other_relationship, :string
      attribute :percentage_owned, :decimal

      validates :name, :relationship, :percentage_owned, presence: true
      validates :other_relationship, presence: true, if: :other_relationship?
      validates :relationship, inclusion: {
        in: PropertyRelationshipType.values.map(&:to_s).push(PropertyOwner::OTHER_RELATIONSHIP)
      }

      validates_numericality_of :percentage_owned, greater_than: 0.0, less_than: 100.0

      # Needed for `#fields_for` to render the uuids as hidden fields
      def persisted?
        id.present?
      end

      def other_relationship?
        relationship == PropertyOwner::OTHER_RELATIONSHIP
      end
    end
  end
end
