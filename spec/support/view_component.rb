require 'view_component/test_helpers'
require 'capybara/rspec'

RSpec.configure do |config|
  config.include ViewComponent::TestHelpers, type: :component
  config.include Capybara::RSpecMatchers, type: :component

  def render_summary_component(component)
    with_request_url "/applications/#{crime_application.id}/edit" do
      render_inline(component)
    end
  end
end
