module TaskList
  class StatusTag < BaseRenderer
    attr_reader :status

    DEFAULT_CLASSES = %w[govuk-tag app-task-list__tag].freeze

    STATUSES = {
      TaskStatus::COMPLETED => nil,
      TaskStatus::IN_PROGRESS => 'govuk-tag--blue',
      TaskStatus::NOT_STARTED => 'govuk-tag--grey',
      TaskStatus::UNREACHABLE => 'govuk-tag--grey',
      TaskStatus::NOT_APPLICABLE => 'govuk-tag--grey',
    }.freeze

    def initialize(crime_application, name:, status:)
      super(crime_application, name:)
      @status = status
    end

    def render
      tag.strong id: tag_id, class: tag_classes do
        t!("tasklist.status.#{status}")
      end
    end

    private

    def tag_classes
      DEFAULT_CLASSES | Array(STATUSES.fetch(status))
    end
  end
end
