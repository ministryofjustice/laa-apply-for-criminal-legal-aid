module Steps
  module Capital
    class PropertyOwnerFieldsetForm < Steps::BaseFormObject
      attribute :_destroy, :boolean, default: false
      attribute :id, :string
      attribute :name, :string
      attribute :relationship, :string
      attribute :custom_relationship, :string
      attribute :percentage_owned, :integer

      validates :name, :relationship, :percentage_owned, presence: true
      validates :custom_relationship, presence: true, if: :custom_relationship?
      validates :relationship, inclusion: {
        in: RelationshipType.values.map(&:to_s).push(PropertyOwner::CUSTOM_RELATIONSHIP)
      }

      # Needed for `#fields_for` to render the uuids as hidden fields
      def persisted?
        id.present?
      end

      def custom_relationship?
        relationship == PropertyOwner::CUSTOM_RELATIONSHIP
      end
    end
  end
end
