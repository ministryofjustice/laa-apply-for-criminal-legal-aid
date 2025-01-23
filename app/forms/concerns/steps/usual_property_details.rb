module Steps
  module UsualPropertyDetails
    extend ActiveSupport::Concern

    included do
      attr_writer :action

      validates :action, presence: true
      validates :action, inclusion: { in: :choices }
    end

    def home_address
      crime_application.applicant.home_address.values_at(
        *::Address::ADDRESS_ATTRIBUTES
      ).compact_blank.join("\r\n")
    end

    def residence_ownership
      crime_application.applicant.residence_type
    end

    private

    # :nocov:
    def persist!
      true
    end
    # :nocov:
  end
end
