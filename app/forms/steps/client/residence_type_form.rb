module Steps
  module Client
    class ResidenceTypeForm < Steps::BaseFormObject
      include Steps::HasOneAssociation

      has_one_association :applicant

      attribute :residence_type, :value_object, source: ResidenceType
      attribute :relationship_to_owner_of_usual_home_address, :string

      validates :residence_type,
                inclusion: { in: :choices }

      validates :relationship_to_owner_of_usual_home_address,
                presence: true,
                if: -> { someone_else? }

      def choices
        ResidenceType.values
      end

      private

      def changed?
        # The attribute is a `value_object`, overriding generic `#changed?`
        !applicant.residence_type.eql?(residence_type.to_s) ||
          !applicant.relationship_to_owner_of_usual_home_address.eql?(relationship_to_owner_of_usual_home_address)
      end

      def persist!
        return true unless changed?

        reset_home_address if residence_type&.none?
        applicant.update(attributes.merge(attributes_to_reset))
      end

      def attributes_to_reset
        {
          'relationship_to_owner_of_usual_home_address' => (if someone_else?
                                                              relationship_to_owner_of_usual_home_address
                                                            end)
        }
      end

      def someone_else?
        residence_type&.someone_else?
      end

      def reset_home_address
        return unless crime_application.applicant.home_address?

        crime_application.applicant.home_address.destroy!
      end
    end
  end
end
