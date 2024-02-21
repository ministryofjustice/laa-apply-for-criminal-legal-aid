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

RSpec.shared_examples 'a payment form' do |payment_class|
  subject { payment_class.new(arguments) }

  let(:arguments) do
    {
      crime_application: crime_application,
      types: allowed_types,
    }
  end

  let(:crime_application) { CrimeApplication.new(case: case_record) }
  let(:record_id) { '12345' }
  let(:case_record) { Case.new }

  describe 'types' do
    let(:example_attribute_data) do
      { 'amount_in_pounds' => 23.30, 'frequency' => 'week' }
    end

    context 'when defined as an attribute' do
      it 'responds with a fieldset form', :aggregate_failures do
        allowed_types.each do |type|
          subject.public_send("#{type}=", example_attribute_data)
          response = subject.public_send(type)

          expect(response).to be_a fieldset_form_class
          expect(response.amount).to eq 2330
          expect(response.payment_type).to eq type
          expect(response.frequency).to eq 'week'
          expect(response.details).to be_nil
        end
      end

      it 'persists the fieldset form when attribute is initially set' do
        expect do
          allowed_types.each { |type| subject.public_send("#{type}=", example_attribute_data) }
        end.to change(payments, :size).by(allowed_types.size)
      end

      it 'replaces the persisted fieldset form when attribute is reset' do # rubocop:disable RSpec/MultipleExpectations, RSpec/ExampleLength
        subject.other = {
          'amount_in_pounds' => 103.26,
          'frequency' => 'month',
          'details' => 'Earned some cash selling furniture'
        }
        record = payments.find_by(payment_type: 'other')
        expect(payments.size).to eq 1
        expect(record.amount).to eq 10_326
        expect(record.frequency).to eq 'month'
        expect(record.details).to eq 'Earned some cash selling furniture'

        subject.other = {
          'amount_in_pounds' => 8982.10,
          'frequency' => 'annual'
        }
        record = payments.find_by(payment_type: 'other')
        expect(payments.size).to eq 1
        expect(record.amount).to eq 898_210
        expect(record.frequency).to eq 'annual'
        expect(record.details).to be_nil
      end
    end
  end

  describe '#ordered_payment_types' do
    it 'outputs payment types in the correct order' do
      expect(subject.ordered_payment_types).to match_array(allowed_types)
    end
  end

  describe '#checked?' do
    context 'when persisted record exists' do
      before do
        # Persist
        subject.other = { 'amount_in_pounds' => 105.50, 'frequency' => 'four_weeks' }
      end

      it 'returns true' do
        expect(subject.checked?('other')).to be true
      end
    end

    # When user selects a payment type but the data is invalid e.g.
    # missing amount, missing frequency, assume the type itself was 'checked'
    context 'record was submitted but not persisted' do
      subject(:form) do
        described_class.new(
          crime_application: crime_application,
          types: %w[rent] # Submitted/initialising payment values
        )
      end

      it 'returns true for submitted value' do
        expect(subject.checked?('rent')).to be true
      end

      it 'returns false for unsubmitted value' do
        expect(subject.checked?('other')).to be false
      end
    end

    context 'with invalid type' do
      it 'throws exception' do
        expect { subject.checked?('bad type') }.to raise_error(NoMethodError, /undefined method `bad type'/)
      end
    end
  end

  describe '#save' do
    context 'when `none` type' do
      subject(:form) do
        described_class.new(
          crime_application: crime_application,
          types: %w[none]
        )
      end

      before do
        subject.valid?
      end

      it 'saves nothing' do
        expect(payments.size).to eq 0

        # Always true because child records must already be persisted beforehand.
        # The `.save` is called as part of the BaseFormObject lifecycle
        expect(subject.save).to be true

        expect(subject.errors.size).to eq 0
      end
    end

    context 'when no attributes are invoked' do
      subject(:form) do
        described_class.new(
          crime_application: crime_application,
          types: %w[]
        )
      end

      it 'saves nothing' do
        expect(payments.size).to eq 0
        expect(subject.save).to be true # Always true
        expect(subject.errors.size).to eq 0
      end
    end
  end
end
