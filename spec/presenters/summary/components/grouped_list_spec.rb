require 'rails_helper'

class MockComponent < ViewComponent::Base
  def initialize(mock:, mock_counter:, show_actions:, show_record_actions:, crime_application:) # rubocop:disable Lint/UnusedMethodArgument
    @type = mock.type
    @count = mock_counter
    super()
  end

  def call
    tag.p "#{@type} #{@count}"
  end
end

RSpec.describe Summary::Components::GroupedList, type: :component do
  subject do
    described_class.new(
      items: [double(type: 'foo'), double(type: 'bar'), double(type: 'foo')],
      group_by: :type,
      item_component: MockComponent,
      show_actions: true,
      crime_application: nil
    )
  end

  it 'groups the items and renders them with the correct counter' do
    render_inline(subject)
    expect(page.all('p').map(&:text)).to match ['foo 0', 'foo 1', 'bar 0']
  end
end
