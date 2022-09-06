module Steps
  module Case
    class CodefendantFieldsetForm < Steps::BaseFormObject
      attribute :_destroy, :boolean
      attribute :id, :string
      attribute :first_name, :string
      attribute :last_name, :string
      attribute :conflict_of_interest, :value_object, source: YesNoAnswer

      validates_presence_of :first_name,
                            :last_name

      validates_inclusion_of :conflict_of_interest, in: :choices

      def choices
        YesNoAnswer.values
      end

      # Needed for `#fields_for` to render the uuids as hidden fields
      def persisted?
        id.present?
      end
    end
  end
end
