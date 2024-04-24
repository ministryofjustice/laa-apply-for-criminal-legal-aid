module Summary
  module Sections
    class ContactDetails < Sections::BaseSection
      def show?
        applicant.present? && super
      end

      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      def answers
        answers = []

        if residence_type?
          answers.push(Components::ValueAnswer.new(
                         :residence_type, applicant.residence_type,
                         change_path: edit_steps_client_residence_type_path
                       ))
        end

        if someone_else_residence_type?
          answers.push(Components::FreeTextAnswer.new(
                         :relationship_to_someone_else, applicant.relationship_to_someone_else,
                         change_path: edit_steps_client_residence_type_path
                       ))
        end

        answers << [
          Components::FreeTextAnswer.new(
            :home_address, full_address(home_address), show: true,
            change_path: change_path(home_address)
          ),

          Components::ValueAnswer.new(
            :correspondence_address_type, applicant.correspondence_address_type,
            change_path: edit_steps_client_contact_details_path
          ),

          Components::FreeTextAnswer.new(
            :correspondence_address, full_address(correspondence_address),
            change_path: change_path(correspondence_address)
          ),

          Components::FreeTextAnswer.new(
            :telephone_number, applicant.telephone_number, show: true,
            change_path: edit_steps_client_contact_details_path
          ),
        ]

        answers.flatten.select(&:show?)
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

      def change_path(address)
        return unless address.try(:to_param)

        if address.lookup_id.present?
          # A postcode lookup was performed and an address was selected
          edit_steps_address_results_path(address)
        elsif address.address_line_one.present?
          # Postcode lookup didn't return correct results, failed, or manual address
          edit_steps_address_details_path(address)
        else
          # No address present, we take them to the postcode lookup
          edit_steps_address_lookup_path(address)
        end
      end

      def full_address(address)
        return unless address

        address.values_at(
          *Address::ADDRESS_ATTRIBUTES
        ).compact_blank.join("\r\n")
      end

      def someone_else_residence_type?
        crime_application.applicant.residence_type == 'someone_else'
      end

      def residence_type?
        crime_application.applicant.residence_type.present?
      end
    end
  end
end
