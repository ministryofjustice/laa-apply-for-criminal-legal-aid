module Steps
  module Case
    class CodefendantFieldsetForm < Steps::BaseFormObject
      attribute :_destroy, :boolean
      attribute :id, :string
      attribute :first_name, :string
      attribute :last_name, :string

      validates_presence_of :first_name,
                            :last_name

      # Needed for `#fields_for` to render the uuids as hidden fields
      def persisted?
        id.present?
      end
    end
  end
end
