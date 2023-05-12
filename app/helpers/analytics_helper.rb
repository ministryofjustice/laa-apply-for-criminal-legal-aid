module AnalyticsHelper
  def analytics_tracking_id
    Rails.configuration.x.analytics.ga_tracking_id
  end
end
