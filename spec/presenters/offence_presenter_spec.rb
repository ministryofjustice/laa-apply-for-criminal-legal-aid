require 'rails_helper'

RSpec.describe OffencePresenter do
  let(:offence) do
    instance_double(
      Offence,
      offence_class: 'H'
    )
  end

  describe '#offence_class' do
    subject { described_class.new(offence).offence_class }

    it { is_expected.to eq('Class H') }
  end
end
