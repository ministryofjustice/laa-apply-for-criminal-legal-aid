module TaskList
  class Collection
    attr_reader :view, :crime_application

    delegate :application_type, to: :crime_application

    # Sections and tasks will show in the same order they are declared here
    # Implement each task logic in individual classes in `app/presenters/tasks`
    SECTIONS = {
      initial: [
        [:about_your_client, [:client_details, :partner_details, :passporting_benefit_check]],
        [:case_details,     [:case_details, :ioj]],
        [:means_assessment, [:income_assessment, :outgoings_assessment, :capital_assessment]],
        [:support_evidence, [:evidence_upload]],
        [:more_information, [:more_information]],
        [:review_confirm,   [:review, :declaration]],
      ],
      change_in_financial_circumstances: [
        [:about_your_client, [:client_details, :partner_details, :passporting_benefit_check]],
        [:case_details,     [:case_details, :ioj]],
        [:means_assessment, [:income_assessment, :outgoings_assessment, :capital_assessment]],
        [:support_evidence, [:evidence_upload]],
        [:more_information, [:more_information]],
        [:review_confirm,   [:review, :declaration]],
      ],
      post_submission_evidence: [
        [:support_evidence, [:evidence_upload]],
        [:more_information, [:more_information]],
        [:review_confirm,   [:review, :declaration]],
      ]
    }.freeze

    def initialize(crime_application:)
      @crime_application = crime_application
    end

    def completed
      all_tasks.select { |task| task.status.completed? }
    end

    def applicable
      all_tasks.reject { |task| task.status.not_applicable? }
    end

    def sections
      @sections ||= SECTIONS.fetch(application_type.to_sym).map do |name, task_names|
        Section.new(crime_application, name:, task_names:)
      end
    end

    private

    def all_tasks
      @all_tasks ||= sections.map(&:tasks).flatten
    end
  end
end
