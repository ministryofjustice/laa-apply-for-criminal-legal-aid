module Steps
  module Case
    class OffenceDateFieldsetForm < Steps::BaseFormObject
      attribute :_destroy, :boolean
      attribute :id, :string
      attribute :date_from, :multiparam_date
      attribute :date_to, :multiparam_date

      validates :date_from, presence: true, multiparam_date: true
      validates :date_to, multiparam_date: true

      validate :date_from_before_date_to

      # Needed for `#fields_for` to render the uuids as hidden fields
      def persisted?
        id.present?
      end

      private

      def date_from_before_date_to
        return unless date_from.is_a?(Date) && date_to.is_a?(Date)

        errors.add(:date_to, :before_date_from) if date_to < date_from
      end
    end
  end
end
