class TaskStatus < ValueObject
  VALUES = [
    COMPLETED = new(:completed),
    IN_PROGRESS = new(:in_progress),
    NOT_STARTED = new(:not_started),
    UNREACHABLE = new(:unreachable),
    NOT_APPLICABLE = new(:not_applicable),
  ].freeze

  def enabled?
    [COMPLETED, IN_PROGRESS, NOT_STARTED].include?(self)
  end
end
