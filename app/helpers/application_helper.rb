module ApplicationHelper
  def service_name
    t('layouts.header.service_name')
  end

  def title(page_title)
    content_for(
      :page_title, [page_title.presence, service_name, 'GOV.UK'].compact.join(' - ')
    )
  end

  # In local/test we raise an exception, so we are aware a title has not been set
  def fallback_title
    exception = StandardError.new("page title missing: #{controller_name}##{action_name}")
    raise exception if Rails.application.config.consider_all_requests_local

    title ''
  end

  def hours_or_minutes(minutes)
    if (minutes % 1.hour).zero?
      t('hours_or_minutes.hours', count: minutes.in_hours.to_i)
    else
      t('hours_or_minutes.minutes', count: minutes.in_minutes.to_i)
    end
  end

  def present(model, presenter_class = nil)
    (presenter_class || [model.class, :Presenter].join.demodulize.constantize).new(model)
  end
end
