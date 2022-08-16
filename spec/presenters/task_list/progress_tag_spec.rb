require 'rails_helper'

RSpec.describe TaskList::ProgressTag do
  include ActionView::TestCase::Behavior

  subject { described_class.new(view, name: name, status: status) }

  let(:name) { :foobar_task }

  describe 'STATUS_TAGS' do
    it 'contains a map of statuses and their CSS classes' do
      expect(
        described_class::STATUSES
      ).to eq(
        completed: nil,
        in_progress: 'govuk-tag--blue',
        not_started: 'govuk-tag--grey',
        unreachable: 'govuk-tag--grey',
        not_applicable: 'govuk-tag--grey',
      )
    end
  end

  describe '.render' do
    it 'initialises the object and call the render instance method' do
      expect(
        described_class
      ).to receive(:new).with(view, name: 'name', status: 'status')

      described_class.new(view, name: 'name', status: 'status')
    end
  end

  describe '#render' do
    context 'for a `completed` status' do
      let(:status) { :completed }
      it { expect(subject.render).to eq('<strong id="foobar_task-status" class="govuk-tag app-task-list__tag">Completed</strong>') }
    end

    context 'for an `in_progress` status' do
      let(:status) { :in_progress }
      it { expect(subject.render).to eq('<strong id="foobar_task-status" class="govuk-tag app-task-list__tag govuk-tag--blue">In progress</strong>') }
    end

    context 'for a `not_started` status' do
      let(:status) { :not_started }
      it { expect(subject.render).to eq('<strong id="foobar_task-status" class="govuk-tag app-task-list__tag govuk-tag--grey">Not started</strong>') }
    end

    context 'for an `unreachable` status' do
      let(:status) { :unreachable }
      it { expect(subject.render).to eq('<strong id="foobar_task-status" class="govuk-tag app-task-list__tag govuk-tag--grey">Cannot yet start</strong>') }
    end

    context 'for a `not_applicable` status' do
      let(:status) { :not_applicable }
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
