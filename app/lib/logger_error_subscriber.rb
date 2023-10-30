# This subscriber will log exceptions to stdout, when using
# new Rails error reporting API (i.e. `Rails.error.handle`, etc.)
class LoggerErrorSubscriber
  def report(error, *args)
    Rails.logger.error [error.class, error, args.first, error.backtrace&.first].join("\n")
  end
end
