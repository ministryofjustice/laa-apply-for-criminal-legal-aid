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
            Components::ValueAnswer.new(
              :application_type, crime_application.application_type
            ),
            Components::ReferenceAnswer.new(
              :reference, crime_application.reference,
            ),
          ]

        if cifc?
          relevant_answers.push(Components::FreeTextAnswer.new(
                                  :pre_cifc_reason, crime_application.pre_cifc_reason,
                                  change_path: edit_steps_circumstances_pre_cifc_reason_path,
                                ))

          relevant_answers.push(Components::FreeTextAnswer.new(
                                  :pre_cifc_maat_id_or_usn, pre_cifc_reference_value,
                                  show: crime_application.pre_cifc_reference_number.present?,
                                  change_path: edit_steps_circumstances_pre_cifc_reference_number_path,
                                  i18n_opts: { ref_type: pre_cifc_reference_name }
                                ))
        end

        if !pse? && !cifc?
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

          # PSE submissions do not have a datestamp:
          completed_answers.shift if pse?

          (relevant_answers += completed_answers).select(&:show?)
        end

        relevant_answers
      end
      # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

      def heading
        :application_details
      end

      private

      def provider_details
        @provider_details ||= crime_application.provider_details
      end

      def show_overview_details?
        return true if pse?

        crime_application.kase.present?
      end

      def pse?
        crime_application.application_type == 'post_submission_evidence'
      end

      def cifc?
        crime_application.application_type == 'change_in_financial_circumstances'
      end

      def pre_cifc_reference_name
        return '' if crime_application.pre_cifc_reference_number.nil?

        crime_application.pre_cifc_maat_id.present? ? 'MAAT ID' : 'USN'
      end

      def pre_cifc_reference_value
        return '' if crime_application.pre_cifc_reference_number.nil?

        crime_application.pre_cifc_maat_id.presence || crime_application.pre_cifc_usn.presence
      end
    end
  end
end
