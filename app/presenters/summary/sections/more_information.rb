module Summary
  module Sections
    class MoreInformation < Sections::BaseSection
      def show?
        crime_application.case.present? && super
      end

      def answers
        [
          Components::FreeTextAnswer.new(
            :additional_information,
            crime_application.additional_information,
            change_path: edit_steps_submission_more_information_path(crime_application)
          )
        ]
      end
    end
  end
end
