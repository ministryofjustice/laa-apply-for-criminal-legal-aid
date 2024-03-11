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

  describe '#amount' do
    let(:amount) { 0 }
    let(:frequency) { 'week' }

    before do
      subject.attributes['amount'] = amount
      subject.valid?
    end

    context 'when 0' do
      let(:amount) { 0 }

      it { is_expected.not_to be_valid }
      it { expect(subject.errors.of_kind?(:amount, :greater_than)).to be(true) }
    end

    context 'when less than 0' do
      let(:amount) { -1 }

      it { is_expected.not_to be_valid }
      it { expect(subject.errors.of_kind?(:amount, :greater_than)).to be(true) }
    end

    context 'when blank' do
      let(:amount) { '' }

      it { is_expected.not_to be_valid }
      it { expect(subject.amount).to eq '' }
      it { expect(subject.errors.of_kind?(:amount, :not_a_number)).to be(true) }
    end

    context 'when not a number' do
      let(:amount) { ' twelve ' }

      it { expect(subject.errors.of_kind?(:amount, :not_a_number)).to be(true) }
    end

    context 'when valid' do
      let(:amount) { 82.90 }

      it 'displays a stringified number' do
        expect(subject).to be_valid
        expect(subject.amount).to eq '82.90'
      end
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
      { 'amount' => 23.30, 'frequency' => 'week' }
    end

    context 'when defined as an attribute' do
      it 'responds with a fieldset form', :aggregate_failures do
        allowed_types.each do |type|
          subject.public_send(:"#{type}=", example_attribute_data)
          response = subject.public_send(type)

          expect(response).to be_a fieldset_form_class
          expect(response.amount).to eq '23.30'
          expect(response.payment_type).to eq type
          expect(response.frequency).to eq 'week'

          expect(response.details).to be_nil if response.respond_to?(:details)
          expect(response.case_reference).to be_nil if response.respond_to?(:case_reference)
        end
      end

      it 'persists the fieldset form when attribute is initially set' do
        expect do
          allowed_types.each { |type| subject.public_send(:"#{type}=", example_attribute_data) }
        end.to change(payments, :size).by(allowed_types.size)
      end

      it 'replaces the persisted fieldset form when attribute is reset' do
        subject.public_send(:"#{allowed_types.first}=", { 'amount' => 103.26, 'frequency' => 'month' })

        record = payments.find_by(payment_type: allowed_types.first)
        expect(payments.size).to eq 1
        expect(record.amount).to eq '103.26'
        expect(record.frequency).to eq PaymentFrequencyType::MONTHLY

        subject.public_send(:"#{allowed_types.first}=", { 'amount' => 8982.10, 'frequency' => 'annual' })

        record = payments.find_by(payment_type: allowed_types.first)
        expect(payments.size).to eq 1
        expect(record.amount).to eq '8982.10'
        expect(record.frequency).to eq PaymentFrequencyType::ANNUALLY
      end

      it 'persists amount as an integer' do
        subject.public_send(:"#{allowed_types.first}=", example_attribute_data)
        record = payments.find_by(payment_type: allowed_types.first)

        expect(record.amount_before_type_cast).to eq 2330
        expect(record.amount_before_type_cast).to be_a Integer
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
        subject.public_send(:"#{allowed_types.first}=", { 'amount' => 105.50, 'frequency' => 'four_weeks' })
      end

      it 'returns true' do
        expect(subject.checked?(allowed_types.first)).to be true
      end
    end

    # When user selects a payment type but the data is invalid e.g.
    # missing amount, missing frequency, assume the type itself was 'checked'
    context 'record was submitted but not persisted' do
      subject(:form) do
        described_class.new(
          crime_application: crime_application,
          types: [allowed_types.first] # Submitted/initialising payment values
        )
      end

      it 'returns true for submitted value' do
        expect(subject.checked?(allowed_types.first)).to be true
      end

      it 'returns false for unsubmitted value' do
        expect(subject.checked?(allowed_types.second)).to be false
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

RSpec.shared_examples 'a basic amount with frequency' do |payment_class|
  describe 'amount with frequency' do
    subject(:form) { payment_class.new(arguments) }

    # Ensure thorough validity test in host spec
    context 'when amount and frequency are valid' do
      let(:arguments) do
        { 'amount' => '12239', 'frequency' => 'month' }.merge(crime_application:)
      end

      it 'has amount and frquency' do
        expect(subject.amount).to eq '12239'
        expect(subject.frequency).to eq PaymentFrequencyType::MONTHLY
      end
    end

    context 'when amount is less than 0' do
      let(:arguments) do
        { 'amount' => '-122', 'frequency' => 'month' }.merge(crime_application:)
      end

      it 'is invalid' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:amount, :greater_than)).to be(true)
      end
    end

    context 'when amount is not a number' do
      let(:arguments) do
        { 'amount' => 'nine quid', 'frequency' => 'month' }.merge(crime_application:)
      end

      it 'is invalid' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:amount, :not_a_number)).to be(true)
      end
    end

    context 'when amount is blank' do
      let(:arguments) do
        { 'amount' => '', 'frequency' => 'month' }.merge(crime_application:)
      end

      it 'is invalid' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:amount, :blank)).to be(true)
      end
    end

    context 'when frequency is not valid' do
      let(:arguments) do
        { 'amount' => '1221', 'frequency' => 'every 2 months' }.merge(crime_application:)
      end

      it 'has a validation error on the field' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:frequency, :inclusion)).to be(true)
      end
    end
  end
end
