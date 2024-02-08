module Summary
  module Sections
    class Overview < Sections::BaseSection
      def show?
        show_overview_details? && super
      end

      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      def answers
        relevant_answers =
          [
            Components::FreeTextAnswer.new(
              :reference, crime_application.reference.to_s,
            ),
          ]

        if FeatureFlags.means_journey.enabled?
          relevant_answers.push(Components::ValueAnswer.new(
                                  :means_tested, crime_application.is_means_tested,
                                  change_path: edit_steps_client_is_means_tested_path
                                ))
        end

        unless crime_application.in_progress?
          completed_answers =
            [
              Components::DateAnswer.new(
                :date_stamp, crime_application.date_stamp,
                i18n_opts: { format: :datetime },
              ),

              Components::DateAnswer.new(
                :date_submitted, crime_application.submitted_at,
                i18n_opts: { format: :datetime },
              ),

              Components::FreeTextAnswer.new(
                :provider_email, provider_details.provider_email,
              ),

              Components::FreeTextAnswer.new(
                :office_code, provider_details.office_code,
              ),
            ]
          (relevant_answers += completed_answers).select(&:show?)
        end

        relevant_answers
      end
      # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

      private

      def provider_details
        @provider_details ||= crime_application.provider_details
      end

      def show_overview_details?
        crime_application.case.present?
      end
    end
  end
end
