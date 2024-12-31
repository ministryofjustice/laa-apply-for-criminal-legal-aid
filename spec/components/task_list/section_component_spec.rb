require 'rails_helper'

RSpec.describe TaskList::SectionComponent, type: :component do
  let(:section) do
    instance_double TaskList::Section, tasks: tasks, name: :about_your_client
  end

  let(:tasks) { [task] }

  let(:task) do
    instance_double(
      Tasks::CapitalAssessment,
      name: :capital_assessment,
      status: status,
      path: 'path/to/step'
    )
  end

  let(:status) { TaskStatus::NOT_STARTED }

  describe '.new' do
    before do
      render_inline(described_class.new(section:))
    end

    describe 'section heading' do
      subject(:heading) { page.first('h2.govuk-heading-m').text }

      it { is_expected.to eq('About your client') }
    end

    context 'when status is NOT_STARTED' do
      describe 'task list item' do
        subject(:task_list_item) { page.find('.govuk-task-list__item') }

        it { is_expected.to have_link(text: 'Capital assessment', href: 'path/to/step') }
      end

      describe 'status' do
        subject(:status_tag) { page.first('.govuk-task-list__status') }

        it { is_expected.to have_css('.govuk-tag--blue') }
        it { is_expected.to have_text('Not started') }
      end
    end

    context 'when status is COMPLETED' do
      let(:status) { TaskStatus::COMPLETED }

      describe 'task list item' do
        subject(:task_list_item) { page.find('.govuk-task-list__item') }

        it { is_expected.to have_link(text: 'Capital assessment', href: 'path/to/step') }
      end

      describe 'status' do
        subject(:status_tag) { page.first('.govuk-task-list__status') }

        it { is_expected.to have_no_css('.govuk-tag') }
        it { is_expected.to have_text('Completed') }
      end
    end

    context 'when status is IN_PROGRESS' do
      let(:status) { TaskStatus::IN_PROGRESS }

      describe 'task list item' do
        subject(:task_list_item) { page.find('.govuk-task-list__item') }

        it { is_expected.to have_link(text: 'Capital assessment', href: 'path/to/step') }
      end

      describe 'status' do
        subject(:status_tag) { page.first('.govuk-task-list__status') }

        it { is_expected.to have_css('.govuk-tag--light-blue') }
        it { is_expected.to have_text('In progress') }
      end
    end

    context 'when status is UNREACHABLE' do
      let(:status) { TaskStatus::UNREACHABLE }

      describe 'task list item' do
        subject(:task_list_item) { page.find('.govuk-task-list__item') }

        it { is_expected.to have_no_link }
        it { is_expected.to have_css('.govuk-task-list__status--cannot-start-yet') }
      end

      describe 'status' do
        subject(:status_tag) { page.first('.govuk-task-list__status') }

        it { is_expected.to have_no_css('.govuk-tag') }
        it { is_expected.to have_text('Cannot start yet') }
      end
    end

    context 'when status is NOT_APPLICABLE' do
      let(:status) { TaskStatus::NOT_APPLICABLE }

      describe 'task list item' do
        subject(:task_list_item) { page.find('.govuk-task-list__item') }

        it { is_expected.to have_no_link }
        it { is_expected.to have_css('.govuk-task-list__status--cannot-start-yet') }
      end

      describe 'status' do
        subject(:status_tag) { page.first('.govuk-task-list__status') }

        it { is_expected.to have_no_css('.govuk-tag') }
        it { is_expected.to have_text('Not applicable') }
      end
    end
  end

  describe '.with_collection' do
    let(:sections) do
      TaskList::Collection::SECTIONS[:initial].map do |name, _|
        instance_double(TaskList::Section, tasks: [], name: name)
      end
    end

    before do
      render_inline described_class.with_collection(sections)
    end

    describe 'section headings' do
      subject(:headings) { page.all('h2.govuk-heading-m').map(&:text) }

      it 'prepends the section number to the heading' do
        expect(headings).to eq(
          ['1. About your client', '2. Case details', '3. Means assessment', '4. Supporting evidence',
           '5. More information', '6. Review and confirm']
        )
      end
    end
  end
end
