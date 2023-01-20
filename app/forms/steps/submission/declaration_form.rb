module Steps
  module Submission
    class DeclarationForm < Steps::BaseFormObject
      attribute :legal_rep_first_name, :string
      attribute :legal_rep_last_name, :string
      attribute :legal_rep_telephone, :string

      # Very basic validation to allow numeric and common telephone number symbols
      TEL_REGEXP = /\A[0-9#+()-.]{7,18}\Z/

      validates :legal_rep_first_name,
                :legal_rep_last_name,
                :legal_rep_telephone, presence: true

      validates :legal_rep_telephone,
                format: { with: TEL_REGEXP }

      def legal_rep_telephone=(str)
        super(str.delete(' ')) if str
      end

      private

      def persist!
        crime_application.update(
          attributes.merge(
            additional_attributes
          )
        )

        return true unless changed?

        # Update the signed in provider settings
        record.update(
          attributes.compact_blank
        )
      end

      # Any other non user-editable attributes required
      # before the final submission
      def additional_attributes
        { provider_email: record.email }
      end
    end
  end
end
