module TaskList
  class Collection < SimpleDelegator
    attr_reader :view, :crime_application

    delegate :size, to: :all_tasks
    delegate :tag, :safe_join, to: :view

    # Sections and tasks will show in the same order they are declared here
    # Implement each task logic in individual classes in `app/presenters/tasks`
    SECTIONS = [
      [:client_details,   [:client_details]],
      [:case_details,     [:case_details, :ioj]],
      [:means_assessment, [:income_assessment, :capital_assessment, :check_your_answers, :check_assessment_result]],
      [:support_evidence, [:evidence_upload]],
      [:review_confirm,   [:application_review, :application_submission]],
    ].freeze

    def initialize(view, crime_application:)
      @view = view
      @crime_application = crime_application

      super(collection)
    end

    def render
      tag.ol class: 'app-task-list' do
        safe_join(map(&:render))
      end
    end

    def completed
      all_tasks.select(&:completed?)
    end

    private

    def all_tasks
      map(&:items).flatten
    end

    def collection
      SECTIONS.map.with_index(1) do |(name, tasks), idx|
        Section.new(crime_application, name: name, tasks: tasks, index: idx)
      end
    end
  end
end
