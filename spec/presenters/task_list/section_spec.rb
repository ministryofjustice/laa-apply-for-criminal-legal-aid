require 'rails_helper'

RSpec.describe TaskList::Section do
  subject { described_class.new(crime_application, name: name, tasks: tasks, index: index) }

  let(:name) { :foobar_task }
  let(:tasks) { [:task_one, :task_two] }
  let(:index) { 1 }

  let(:crime_application) { double }

  describe '#items' do
    it 'contains a collection of Task instances' do
      expect(subject.items).to contain_exactly(TaskList::Task, TaskList::Task)
    end

    it 'has the proper attributes' do
      expect(subject.items.map(&:name)).to eq(tasks)
    end
  end

  describe '#render' do
    before do
      # Ensure we don't rely on task locales, so we have predictable tests
      allow(subject).to receive(:t!).with('tasklist.heading.foobar_task').and_return('Foo Bar Heading')

      # We test the Task separately, here we don't need to
      allow_any_instance_of(TaskList::Task).to receive(:render).and_return('[task_markup]')
    end

    it 'renders the expected section HTML element' do
      expect(
        subject.render
      ).to eq(
        '<li>' +
        '<h2 class="app-task-list__section"><span class="app-task-list__section-number">1.</span>Foo Bar Heading</h2>' +
        '<ul class="app-task-list__items">[task_markup][task_markup]</ul>' +
        '</li>'
      )
    end

    context 'has numbered headings' do
      let(:index) { 3 }

      it 'renders the expected section HTML element' do
        expect(
          subject.render
        ).to match(/<span class="app-task-list__section-number">3.<\/span>/)
      end
    end
  end
end
