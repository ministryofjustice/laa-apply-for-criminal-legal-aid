RSpec.shared_examples 'a payment fieldset form' do |fieldset_class|
  subject { fieldset_class.new(arguments) }

  let(:arguments) do
    {
      crime_application: crime_application,
      id: record_id,
      amount: amount,
      frequency: frequency,
    }
  end

  let(:crime_application) { instance_double(CrimeApplication) }
  let(:record_id) { '12345' }

  describe '#persisted?' do
    let(:amount) { 45_134 }
    let(:frequency) { 'month' }

    context 'when the record has an ID' do
      it { expect(subject.persisted?).to be(true) }
    end

    context 'when the record has no ID' do
      let(:record_id) { nil }

      it { expect(subject.persisted?).to be(false) }
    end
  end

  # TODO: CRIMAPP-466 Refactor as Money to prevent
  # auto-type conversion from float to integer
  describe '#amount' do
    let(:amount) { 304.23 }
    let(:frequency) { 'month' }

    it 'saves as integer' do
      expect(subject.amount).to eq 304
    end
  end

  describe '#amount_in_pounds' do
    let(:frequency) { 'week' }
    let(:amount) { 0 }

    before do
      subject.attributes['amount_in_pounds'] = amount_in_pounds
      subject.valid?
    end

    context 'when 0' do
      let(:amount_in_pounds) { 0 }

      it { is_expected.not_to be_valid }
      it { expect(subject.errors.of_kind?(:amount_in_pounds, :greater_than)).to be(true) }
    end

    context 'when less than 0' do
      let(:amount_in_pounds) { -1 }

      it { is_expected.not_to be_valid }
      it { expect(subject.errors.of_kind?(:amount_in_pounds, :greater_than)).to be(true) }
    end

    context 'when blank' do
      let(:amount_in_pounds) { '' }

      it { is_expected.not_to be_valid }
      it { expect(subject.amount_in_pounds).to eq '0.00' }
      it { expect(subject.errors.of_kind?(:amount_in_pounds, :greater_than)).to be(true) }
    end

    context 'when not a number' do
      let(:amount_in_pounds) { ' twelve ' }

      it { expect(subject.errors.of_kind?(:amount_in_pounds, :greater_than)).to be(true) }
    end
  end

  describe '#frequency' do
    let(:amount) { 101.90 }

    before { subject.valid? }

    context 'when blank' do
      let(:frequency) { '' }

      it { is_expected.not_to be_valid }
      it { is_expected.to validate_presence_of(:frequency) }
      it { expect(subject.errors.of_kind?(:frequency, :blank)).to be(true) }
    end

    context 'when not a valid frequency' do
      let(:frequency) { 'every other day' }

      it { is_expected.not_to be_valid }
      it { expect(subject.errors.of_kind?(:frequency, :inclusion)).to be(true) }
    end
  end
end
