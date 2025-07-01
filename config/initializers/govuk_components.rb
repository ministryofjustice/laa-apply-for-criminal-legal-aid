Govuk::Components.configure do |conf|
  conf.default_header_service_name = I18n.t('layouts.header.service_name')
  conf.default_header_homepage_url = 'https://www.gov.uk'
end
