module Steps
  module Income
    class BusinessTypeForm < Steps::BaseFormObject
      attribute :business_type, :value_object, source: BusinessType

      validates :business_type, inclusion: { in: BusinessType.values }
      validates :ownership_type, inclusion: { in: OwnershipType.exclusive }

      attr_accessor :subject

      def choices
        BusinessType.values
      end

      private

      def ownership_type
        subject.ownership_type
      end

      def persist!
        Business.create!(crime_application:, business_type:, ownership_type:)
      end
    end
  end
end
