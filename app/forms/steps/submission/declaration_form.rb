module Steps
  module Submission
    class DeclarationForm < Steps::BaseFormObject
      class ApplicationFulfilmentError < StandardError; end

      attribute :legal_rep_first_name, :string
      attribute :legal_rep_last_name, :string
      attribute :legal_rep_telephone, :string

      # Very basic validation to allow numeric and common telephone number symbols
      TEL_REGEXP = /\A[0-9#+()-.]{7,18}\z/

      validates :legal_rep_first_name,
                :legal_rep_last_name,
                :legal_rep_telephone, presence: true

      validates :legal_rep_telephone,
                format: { with: TEL_REGEXP }

      # This final form object performs a fulfilment validation,
      # essentially a top level sanity check. See `ApplicationFulfilmentValidator`
      validate :application_fulfilment

      def legal_rep_telephone=(str)
        super(str.delete(' ')) if str
      end

      def fulfilment_errors
        FulfilmentErrorsPresenter.new(crime_application).errors
      end

      private

      def application_fulfilment
        return if errors.any? # if the declaration form already has errors
        return if crime_application.valid?(:submission)

        errors.add(:crime_application)

        # report only, will not raise any exception
        Rails.error.report(
          ApplicationFulfilmentError.new(crime_application.errors.full_messages),
          handled: true
        )
      end

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
