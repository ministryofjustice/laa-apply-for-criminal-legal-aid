module Steps
  module Case
    class OffenceDateFieldsetForm < Steps::BaseFormObject
      attribute :_destroy, :boolean
      attribute :id, :string
      attribute :date, :multiparam_date

      validates :date, presence: true, multiparam_date: true

      # Needed for `#fields_for` to render the uuids as hidden fields
      def persisted?
        id.present?
      end
    end
  end
end
