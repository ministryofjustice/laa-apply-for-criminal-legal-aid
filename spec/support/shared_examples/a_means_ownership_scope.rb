RSpec.shared_examples 'it has a means ownership scope' do
  describe '#ownership_types' do
    subject(:ownership_types) { described_class.new.ownership_types }

    context 'when partner included in means' do
      before do
        allow(MeansStatus).to receive(:include_partner?).and_return(true)
      end

      it { is_expected.to eq %w[applicant applicant_and_partner partner] << nil }
    end

    context 'when partner exlcuded from means assesment' do
      before do
        allow(MeansStatus).to receive(:include_partner?).and_return(false)
      end

      it { is_expected.to eq %w[applicant applicant_and_partner] << nil }
    end
  end
end
