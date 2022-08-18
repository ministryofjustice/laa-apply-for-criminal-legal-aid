require 'rails_helper'

RSpec.describe Tasks::BaseTask do
  subject { described_class.new(crime_application: crime_application) }

  let(:crime_application) { instance_double(CrimeApplication) }

  describe '.build' do
    context 'for a task with an implementation class' do
      it 'instantiate the implementation' do
        task = described_class.build(:client_details, crime_application: crime_application)

        expect(task).to be_a(Tasks::ClientDetails)
        expect(task.crime_application).to eq(crime_application)
      end
    end

    context 'for a task without an implementation class' do
      it 'instantiate the implementation' do
        task = described_class.build(:foobar_task, crime_application: crime_application)

        expect(task).to be_a(Tasks::BaseTask)
        expect(task.crime_application).to eq(crime_application)
      end
    end
  end

  describe '#path' do
    it { expect(subject.path).to eq('') }
  end

  describe '#not_applicable?' do
    it { expect(subject.not_applicable?).to eq(true) }
  end

  describe '#status' do
    before do
      allow(subject).to receive(:not_applicable?).and_return(not_applicable)
      allow(subject).to receive(:can_start?).and_return(can_start)
      allow(subject).to receive(:completed?).and_return(completed)
      allow(subject).to receive(:in_progress?).and_return(in_progress)
    end

    let(:not_applicable) { false }
    let(:can_start) { false }
    let(:completed) { false }
    let(:in_progress) { false }

    context 'task is not applicable' do
      let(:not_applicable) { true }
      it { expect(subject.status).to eq(TaskStatus::NOT_APPLICABLE) }
    end

    context 'task can cannot start yet' do
      it { expect(subject.status).to eq(TaskStatus::UNREACHABLE) }
    end

    context 'task is completed' do
      let(:can_start) { true }
      let(:completed) { true }
      it { expect(subject.status).to eq(TaskStatus::COMPLETED) }
    end

    context 'task is in progress' do
      let(:can_start) { true }
      let(:completed) { false }
      let(:in_progress) { true }

      it { expect(subject.status).to eq(TaskStatus::IN_PROGRESS) }
    end

    context 'task is not started' do
      let(:can_start) { true }
      let(:completed) { false }
      let(:in_progress) { false }

      it { expect(subject.status).to eq(TaskStatus::NOT_STARTED) }
    end
  end
end
