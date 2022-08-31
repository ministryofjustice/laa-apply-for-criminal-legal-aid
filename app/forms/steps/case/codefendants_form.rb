module Steps
  module Case
    class CodefendantsForm < Steps::BaseFormObject
      include Steps::HasOneAssociation
      has_one_association :case

      delegate :codefendants_attributes=, to: :kase

      validates_with CodefendantsValidator

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

      def add_blank_codefendant
        kase.codefendants.create!
      end

      private

      def persist!
        kase.save
      end
    end
  end
end
