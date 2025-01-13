require 'rails_helper'

RSpec.describe TaskList::Section do
  subject { described_class.new(crime_application, name:, task_names:) }

  let(:name) { :foobar_task }
  let(:task_names) { [:evidence_upload, :more_information] }

  let(:crime_application) { double }

  describe '#items' do
    it 'contains a collection of Task instances' do
      expect(subject.tasks).to contain_exactly(Tasks::EvidenceUpload, Tasks::MoreInformation)
    end

    it 'has the proper attributes' do
      expect(subject.tasks.map(&:name)).to eq(task_names)
    end
  end
end
