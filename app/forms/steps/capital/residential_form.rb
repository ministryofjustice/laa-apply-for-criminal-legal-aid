module Steps
  module Capital
    class ResidentialForm < PropertyForm
      attribute :house_type, :string
      attribute :other_house_type, :string
      attribute :bedrooms, :integer

      validates :house_type,
                :bedrooms,
                presence: true

      validates :other_house_type, presence: true, if: :other_house_type?

      validates :house_type, inclusion: {
        in: ->(property) { property.house_types.map(&:to_s).push(Property::OTHER_HOUSE_TYPE) }
      }

      def house_types
        HouseType.values
      end

      def before_save
        super
        record.other_house_type = nil unless other_house_type?
      end

      def other_house_type?
        house_type == Property::OTHER_HOUSE_TYPE
      end
    end
  end
end
