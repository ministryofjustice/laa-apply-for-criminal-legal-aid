# This subscriber will log exceptions to stdout, when using
# new Rails error reporting API (i.e. `Rails.error.handle`, etc.)
class LoggerErrorSubscriber
  def report(error, *)
    Rails.logger.error [error, error.backtrace[0]].join("\n")
  end
end
