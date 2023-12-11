module Steps
  module Income
    class DependantFieldsetForm < Steps::BaseFormObject
      attribute :_destroy, :boolean
      attribute :id, :string
      attribute :age, :integer

      validates :age, presence: true, numericality: {
        greater_than_or_equal_to: 0,
        less_than: Dependant::MAX_AGE,
        only_integer: true
      }

      # Needed for `#fields_for` to render the uuids as hidden fields
      def persisted?
        id.present?
      end
    end
  end
end
