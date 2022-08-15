module TaskList
  class ProgressTag < BaseTaskRenderer
    attr_reader :status

    DEFAULT_CLASSES = %w[govuk-tag app-task-list__tag].freeze

    STATUSES = {
      completed: nil,
      in_progress: 'govuk-tag--blue',
      not_started: 'govuk-tag--grey',
      unreachable: 'govuk-tag--grey',
      not_applicable: 'govuk-tag--grey',
    }.freeze

    def initialize(view, name:, status:)
      super(view, name: name)
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
