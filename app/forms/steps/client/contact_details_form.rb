require 'pry'

module Steps
  module Client
    class ContactDetailsForm < Steps::BaseFormObject
      include Steps::HasOneAssociation

      # Very basic validation to allow numeric and common telephone number symbols
      TEL_REGEXP = /\A[0-9#+()-.]{7,18}\Z/

      attribute :telephone_number, :string

      attribute :correspondence_address_type, :string

      has_one_association :applicant

      validates :telephone_number,
                format: { with: TEL_REGEXP },
                presence: true

      validates :correspondence_address_type,
                inclusion: { in: :string_choices },
                presence: true

      def telephone_number=(str)
        super(str.delete(' ')) if str
      end

      def choices
        if applicant_has_home_address?
          CorrespondenceTypeAnswer.values
        else
          CorrespondenceTypeAnswer.values.reject do |val| 
            val.value == :home_address 
          end
        end
      end

      private

      def applicant_has_home_address?
        applicant.has_home_address?
      end

      def string_choices
        choices.map(&:to_s)
      end

      def persist!
        applicant.update(
          attributes
        )
      end
    end
  end
end
