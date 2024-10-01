module Summary
  module Sections
    class DateStampContext < Sections::BaseSection
      def show?
        date_stampable_values_changed? && super
      end

      def editable?
        false
      end

      # rubocop:disable Metrics/MethodLength
      def answers
        [
          Components::DateAnswer.new(
            :date_stamp, date_stamp_context.date_stamp,
            i18n_opts: { format: :datestamp },
          ),
          Components::ChangedDateStampAnswer.new(
            :first_name, date_stamp_context.first_name,
            changed: first_name_changed?,
          ),
          Components::ChangedDateStampAnswer.new(
            :last_name, date_stamp_context.last_name,
            changed: last_name_changed?,
          ),
          Components::ChangedDateStampAnswer.new(
            :date_of_birth, date_stamp_context.date_of_birth,
            i18n_opts: { format: :dob },
            changed: date_of_birth_changed?,
          ),
        ]
      end
      # rubocop:enable Metrics/MethodLength

      private

      def date_stampable_values_changed?
        return false if applicant.blank? || date_stamp_context.blank?

        first_name_changed? || last_name_changed? || date_of_birth_changed?
      end

      def applicant
        @applicant ||= crime_application.applicant
      end

      def date_stamp_context
        @date_stamp_context ||= crime_application.date_stamp_context
      end

      def first_name_changed?
        applicant.first_name != date_stamp_context.first_name
      end

      def last_name_changed?
        applicant.last_name != date_stamp_context.last_name
      end

      def date_of_birth_changed?
        applicant.date_of_birth != date_stamp_context.date_of_birth
      end
    end
  end
end
