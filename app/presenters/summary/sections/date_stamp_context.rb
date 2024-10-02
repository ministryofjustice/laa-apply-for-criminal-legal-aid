module Summary
  module Sections
    class DateStampContext < Sections::BaseSection
      def show?
        date_stampable_values_changed? && super
      end

      def editable?
        false
      end

      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      def answers
        answers = [
          Components::DateAnswer.new(
            :date_stamp, date_stamp_context.date_stamp,
            i18n_opts: { format: :datestamp },
            show: date_stamp_context.date_stamp.present?,
          ),
          Components::ChangedDateStampAnswer.new(
            :first_name, date_stamp_context.first_name,
            changed: first_name_changed?,
            show: date_stamp_context.first_name.present?,
          ),
          Components::ChangedDateStampAnswer.new(
            :last_name, date_stamp_context.last_name,
            changed: last_name_changed?,
            show: date_stamp_context.last_name.present?,
          ),
          Components::ChangedDateStampAnswer.new(
            :date_of_birth, date_stamp_context.date_of_birth,
            i18n_opts: { format: :dob },
            changed: date_of_birth_changed?,
            show: date_stamp_context.date_of_birth.present?,
          ),
        ]

        answers.select(&:show?)
      end
      # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

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
        return false if date_stamp_context.first_name.blank?

        applicant.first_name != date_stamp_context.first_name
      end

      def last_name_changed?
        return false if date_stamp_context.last_name.blank?

        applicant.last_name != date_stamp_context.last_name
      end

      def date_of_birth_changed?
        return false if date_stamp_context.date_of_birth.blank?

        applicant.date_of_birth != date_stamp_context.date_of_birth
      end
    end
  end
end
