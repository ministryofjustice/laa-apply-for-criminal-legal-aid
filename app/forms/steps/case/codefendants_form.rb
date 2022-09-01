module Steps
  module Case
    class CodefendantsForm < Steps::BaseFormObject
      include Steps::HasOneAssociation
      has_one_association :case

      delegate :codefendants_attributes=, to: :kase

      validates_with CodefendantsValidator, unless: :any_marked_for_destruction?

      def codefendants
        @codefendants ||= begin
          add_blank_codefendant if kase.codefendants.empty? # temporary until we have previous step

          kase.codefendants.map do |codefendant|
            CodefendantFieldsetForm.build(
              codefendant, crime_application: crime_application
            )
          end
        end
      end

      def any_marked_for_destruction?
        codefendants.any?(&:_destroy)
      end

      def show_destroy?
        codefendants.size > 1
      end

      def add_blank_codefendant
        kase.codefendants.create!
      end

      private

      # If validation passes, the actual saving of the `case` performs
      # the updates or destroys of the associated `codefendant` records,
      # as we are using `accepts_nested_attributes_for`
      def persist!
        kase.save
      end
    end
  end
end
