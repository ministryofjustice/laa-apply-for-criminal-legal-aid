require 'rails_helper'

RSpec.describe TaskList::Task do
  include ActionView::TestCase::Behavior

  subject { described_class.new(view, name: name) }

  let(:name) { :foobar_task }

  describe '.render' do
    it 'initialises the object and call the render instance method' do
      expect(
        described_class
      ).to receive(:new).with(view, name: 'name')

      described_class.new(view, name: 'name')
    end
  end

  describe '#render' do
    # Ensure we don't rely on any real locales, so we have predictable tests
    before do
      allow(subject).to receive(:t!).with('tasklist.task.foobar_task').and_return('Foo Bar Task Locale')
      allow(subject).to receive(:t!).with('tasklist.task.not_applicable').and_return('Not applicable')
    end

    # NOTE: for now there is no logic behind to know which status tag to render,
    # or the link to the corresponding step page, etc. That will come next.
    it 'renders the task HTML element with its status tag' do
      expect(
        subject.render
      ).to eq(
        '<li class="app-task-list__item">' +
        '<span class="app-task-list__task-name">Foo Bar Task Locale</span>' +
        '<strong id="foobar_task-status" class="govuk-tag app-task-list__tag govuk-tag--grey">Not applicable</strong>' +
        '</li>'
      )
    end
  end
end
