module Summary
  module Sections
    class ContactDetails < Sections::BaseSection
      def name
        :contact_details
      end

      def show?
        applicant.present? && super
      end

      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      def answers
        [
          Components::FreeTextAnswer.new(
            :home_address, full_address(home_address), show: true,
            change_path: address_path(home_address)
          ),

          Components::ValueAnswer.new(
            :correspondence_address_type, applicant.correspondence_address_type,
            change_path: edit_steps_client_contact_details_path
          ),

          Components::FreeTextAnswer.new(
            :correspondence_address, full_address(correspondence_address),
            change_path: address_path(correspondence_address)
          ),

          Components::FreeTextAnswer.new(
            :telephone_number, applicant.telephone_number,
            change_path: edit_steps_client_contact_details_path
          ),
        ].select(&:show?)
      end
      # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

      private

      def applicant
        @applicant ||= crime_application.applicant
      end

      def home_address
        applicant.home_address
      end

      def correspondence_address
        applicant.correspondence_address
      end

      def address_path(address)
        edit_steps_address_details_path(address) if address
      end

      def full_address(address)
        return unless address

        address.slice(
          :address_line_one,
          :address_line_two,
          :postcode,
          :city,
          :country
        ).values.compact_blank.join("\r\n")
      end
    end
  end
end
