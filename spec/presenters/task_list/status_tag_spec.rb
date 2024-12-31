require 'rails_helper'

RSpec.describe TaskList::StatusTag do
  describe '#to_hash' do
    subject { status_tag.to_hash }

    let(:status) { TaskStatus::IN_PROGRESS }
    let(:status_tag) { described_class.new(status:) }

    context 'when status is IN_PROGRESS' do
      let(:status) { TaskStatus::IN_PROGRESS }

      it 'includes the status as a tag component' do
        expect(subject[:text]).to eq(
          '<strong class="govuk-tag govuk-tag--light-blue">In progress</strong>'
        )
      end

      it 'does not set cannot_start_yet' do
        expect(subject[:cannot_start_yet]).to be false
      end
    end

    context 'when status is UNREACHABLE' do
      let(:status) { TaskStatus::UNREACHABLE }

      it 'includes the status as text only' do
        expect(subject[:text]).to eq('Cannot start yet')
      end

      it 'sets cannot_start_yet to true' do
        expect(subject[:cannot_start_yet]).to be true
      end
    end

    context 'when status is NOT_APPLICABLE' do
      let(:status) { TaskStatus::NOT_APPLICABLE }

      it 'includes the status as text only' do
        expect(subject[:text]).to eq('Not applicable')
      end

      it 'sets cannot_start_yet to true' do
        expect(subject[:cannot_start_yet]).to be true
      end
    end

    context 'when status is COMPLETED' do
      let(:status) { TaskStatus::COMPLETED }

      it 'includes the status as text only' do
        expect(subject[:text]).to eq('Completed')
      end

      it 'sets cannot_start_yet to true' do
        expect(subject[:cannot_start_yet]).to be false
      end
    end

    context 'when status is NOT_STARTED' do
      let(:status) { TaskStatus::NOT_STARTED }

      it 'includes the status as a tag component' do
        expect(subject[:text]).to eq(
          '<strong class="govuk-tag govuk-tag--blue">Not started</strong>'
        )
      end

      it 'does not set cannot_start_yet' do
        expect(subject[:cannot_start_yet]).to be false
      end
    end
  end
end
