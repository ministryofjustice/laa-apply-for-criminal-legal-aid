module Steps
  module Capital
    class ResidentialForm < PropertyForm
      attribute :house_type, :string
      attribute :custom_house_type, :string
      attribute :bedrooms, :integer

      validates :house_type,
                :bedrooms,
                presence: true

      validates :custom_house_type, presence: true, if: :custom_house_type?

      validates :house_type, inclusion: {
        in: ->(property) { property.house_types.map(&:to_s).push(Property::CUSTOM_HOUSE_TYPE) }
      }

      def house_types
        HouseType.values
      end

      def before_save
        super
        record.custom_house_type = nil unless custom_house_type?
      end

      def custom_house_type?
        house_type == Property::CUSTOM_HOUSE_TYPE
      end
    end
  end
end
