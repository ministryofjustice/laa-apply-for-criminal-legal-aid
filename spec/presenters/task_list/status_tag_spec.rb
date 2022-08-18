require 'rails_helper'

RSpec.describe TaskList::StatusTag do
  subject { described_class.new(crime_application, name: name, status: status) }

  let(:name) { :foobar_task }
  let(:crime_application) { double }

  describe '#render' do
    context 'for a `completed` status' do
      let(:status) { TaskStatus::COMPLETED }
      it { expect(subject.render).to eq('<strong id="foobar_task-status" class="govuk-tag app-task-list__tag">Completed</strong>') }
    end

    context 'for an `in_progress` status' do
      let(:status) { TaskStatus::IN_PROGRESS }
      it { expect(subject.render).to eq('<strong id="foobar_task-status" class="govuk-tag app-task-list__tag govuk-tag--blue">In progress</strong>') }
    end

    context 'for a `not_started` status' do
      let(:status) { TaskStatus::NOT_STARTED }
      it { expect(subject.render).to eq('<strong id="foobar_task-status" class="govuk-tag app-task-list__tag govuk-tag--grey">Not started</strong>') }
    end

    context 'for an `unreachable` status' do
      let(:status) { TaskStatus::UNREACHABLE }
      it { expect(subject.render).to eq('<strong id="foobar_task-status" class="govuk-tag app-task-list__tag govuk-tag--grey">Cannot yet start</strong>') }
    end

    context 'for a `not_applicable` status' do
      let(:status) { TaskStatus::NOT_APPLICABLE }
      it { expect(subject.render).to eq('<strong id="foobar_task-status" class="govuk-tag app-task-list__tag govuk-tag--grey">Not applicable</strong>') }
    end

    context 'for an unknown status' do
      let(:status) { :anything_else }

      it 'raises an exception' do
        expect { subject.render }.to raise_error(KeyError)
      end
    end
  end
end
