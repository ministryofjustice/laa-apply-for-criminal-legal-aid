require 'rails_helper'

RSpec.describe SubmissionSerializer::Definitions::Payment do
  subject { described_class.generate(payments) }

  let(:payments) { [payment1] }

  let(:payment1) do
    instance_double(
      Payment,
      type: 'council_tax',
      amount: 100_000,
      frequency: 'annually',
    )
  end

  let(:json_output) do
    [{ type: 'council_tax',
       amount: 100_000,
       frequency: 'annually' }].as_json
  end

  describe '#generate' do
    it { expect(subject).to eq(json_output) }
  end
end
