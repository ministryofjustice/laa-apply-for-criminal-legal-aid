module Steps
  module Capital
    class UsualPropertyDetailsForm < Steps::BaseFormObject
      include UsualPropertyDetails

      attr_reader :residential_property

      def choices
        UsualPropertyDetailsCapitalAnswer.values
      end

      def action
        return if @action.nil?

        UsualPropertyDetailsCapitalAnswer.new(@action)
      end

      private

      def persist!
        return true unless action == UsualPropertyDetailsCapitalAnswer::PROVIDE_DETAILS

        @residential_property = crime_application.properties.create!(property_type: PropertyType::RESIDENTIAL.to_s)
      end
    end
  end
end
