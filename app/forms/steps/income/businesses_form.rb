module Steps
  module Income
    class BusinessesForm < Steps::BaseFormObject
      attribute :trading_name, :string
      attribute :address_line_one, :string
      attribute :address_line_two, :string
      attribute :city, :string
      attribute :country, :string
      attribute :postcode, :string

      validates_presence_of :address_line_one,
                            :city,
                            :country,
                            :postcode

      validates :trading_name, presence: true

      def persist!
        return true unless changed?

        record.update(attributes)
      end

      def form_subject
        SubjectType.new(record.ownership_type)
      end
    end
  end
end
