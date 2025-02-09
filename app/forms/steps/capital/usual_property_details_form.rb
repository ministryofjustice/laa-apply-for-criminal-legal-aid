module Steps
  module Capital
    class UsualPropertyDetailsForm < Steps::BaseFormObject
      include UsualPropertyDetails

      def choices
        UsualPropertyDetailsCapitalAnswer.values
      end

      def action
        return if @action.nil?

        UsualPropertyDetailsCapitalAnswer.new(@action)
      end
    end
  end
end
