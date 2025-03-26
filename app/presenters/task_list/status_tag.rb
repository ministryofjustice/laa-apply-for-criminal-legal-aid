module TaskList
  class StatusTag
    attr_reader :status

    STATUSES = {
      TaskStatus::COMPLETED => nil,
      TaskStatus::IN_PROGRESS => 'light-blue',
      TaskStatus::NOT_STARTED => 'blue',
      TaskStatus::UNREACHABLE => nil,
      TaskStatus::NOT_APPLICABLE => nil
    }.freeze

    def initialize(status:)
      @status = status
    end

    def to_hash
      { text: status_arg, cannot_start_yet: cannot_start_yet? }
    end

    private

    def text
      I18n.t!("tasklist.status.#{status}")
    end

    def cannot_start_yet?
      [TaskStatus::UNREACHABLE, TaskStatus::NOT_APPLICABLE].include?(status)
    end

    def colour
      STATUSES.fetch(status)
    end

    def status_arg
      if colour.blank? || cannot_start_yet?
        text
      else
        GovukComponent::TagComponent.new(text:, colour:).call
      end
    end
  end
end
