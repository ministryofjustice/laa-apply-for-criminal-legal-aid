module Steps
  module Client
    class DetailsForm < Steps::BaseFormObject
      include Steps::HasOneAssociation
      has_one_association :applicant

      attribute :first_name, :string
      attribute :last_name, :string
      attribute :other_names, :string
      attribute :date_of_birth, :multiparam_date

      validates_presence_of :first_name,
                            :last_name

      validates :date_of_birth, presence: true, multiparam_date: true

      validate :date_of_birth_ten_or_more_years_ago

      private

      def date_of_birth_ten_or_more_years_ago
        return unless date_of_birth.is_a?(Date)

        errors.add(:date_of_birth, :client_under_ten) if date_of_birth.beginning_of_day > 10.years.ago
      end

      def persist! # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        return true unless changed?

        ::CrimeApplication.transaction do
          # CRIMAPP-1313 prevents resubmitted application date_of_birth changes to
          # maintain original application means passporting
          if crime_application.resubmission? && changed?(:date_of_birth)
            if applicant.over_18_at_date_stamp? && Applicant.under_18?(Time.zone.now, date_of_birth)
              crime_application.update!(is_means_tested: 'yes')
              applicant.update!(confirm_dwp_result: nil)
            elsif applicant.under_18_at_date_stamp? && Applicant.over_18?(Time.zone.now, date_of_birth)
              applicant.update!(confirm_dwp_result: nil)
              crime_application.update!(is_means_tested: nil)
            end
          end

          # Deliberately not using update! here to ensure general shared specs pattern
          # continues to work as expected
          applicant.update(
            attributes.merge(attributes_to_reset)
          )
        end
      end

      # If the last name or date of birth have changed, the DWP check
      # needs to run again as its result is linked to these attributes
      def attributes_to_reset
        return {} unless changed?(:last_name, :date_of_birth)

        {
          has_nino: nil,
          nino: nil,
          has_arc: nil,
          arc: nil,
          will_enter_nino: nil,
          has_benefit_evidence: nil,
          benefit_type: nil,
          last_jsa_appointment_date: nil,
          benefit_check_result: nil,
        }
      end
    end
  end
end
