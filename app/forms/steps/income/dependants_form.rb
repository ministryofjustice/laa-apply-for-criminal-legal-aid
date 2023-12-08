module Steps
  module Income
    class DependantsForm < Steps::BaseFormObject
      include Steps::HasOneAssociation

      has_one_association :case

      delegate :dependants_attributes=, to: :kase

      validates_with DependantsValidator, unless: :any_marked_for_destruction?

      def dependants
        @dependants ||= kase.dependants.map do |dependant|
          DependantFieldsetForm.build(
            dependant, crime_application:
          )
        end
      end

      def any_marked_for_destruction?
        dependants.any?(&:_destroy)
      end

      def show_destroy?
        dependants.size > 1
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
