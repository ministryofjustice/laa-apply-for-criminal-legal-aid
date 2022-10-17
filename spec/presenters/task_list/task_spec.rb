require 'rails_helper'

RSpec.describe TaskList::Task do
  subject { described_class.new(crime_application, name:) }

  let(:name) { :foobar_task }
  let(:crime_application) { double }

  describe '#render' do
    before do
      # Ensure we don't rely on task locales, so we have predictable tests
      allow(subject).to receive(:t!).with('tasklist.task.foobar_task').and_return('Foo Bar Task Locale')

      allow(
        Tasks::BaseTask
      ).to receive(:build).with(
        name, crime_application:
      ).and_return(task_double)
    end

    let(:task_double) do
      instance_double(Tasks::BaseTask, status: status, path: '/steps/foobar')
    end

    context 'for an enabled task' do
      let(:status) { TaskStatus::IN_PROGRESS }

      it 'renders the expected task HTML element' do
        expect(
          subject.render
        ).to eq(
          '<li class="moj-task-list__item">' \
          '<span class="app-task-list__task-name"><a href="/steps/foobar" aria-describedby="foobar_task-status">' \
          'Foo Bar Task Locale</a></span>' \
          '<strong id="foobar_task-status" class="govuk-tag app-task-list__tag govuk-tag--blue">In progress</strong>' \
          '</li>'
        )
      end
    end

    context 'for a disabled task' do
      let(:status) { TaskStatus::UNREACHABLE }

      it 'renders the expected task HTML element' do
        expect(
          subject.render
        ).to eq(
          '<li class="moj-task-list__item">' \
          '<span class="app-task-list__task-name">Foo Bar Task Locale</span>' \
          '<strong id="foobar_task-status" class="govuk-tag app-task-list__tag govuk-tag--grey">' \
          'Cannot yet start</strong>' \
          '</li>'
        )
      end
    end
  end
end
