RSpec.shared_examples 'a has-one-association form' do |options|
  let(:association_name) { options[:association_name] }
  let(:expected_attributes) { options[:expected_attributes] }
  let(:build_method_name) { "build_#{association_name}".to_sym }

  let(:association_double) { instance_double(association_name.to_s.camelize.constantize) }

  context 'for valid details' do
    context 'when record does not exist' do
      before do
        allow(crime_application).to receive(association_name).and_return(nil)
      end

      it 'creates the record if it does not exist' do
        expect(crime_application).to receive(build_method_name).and_return(association_double)

        expect(association_double).to receive(:update).with(
          expected_attributes
        ).and_return(true)

        expect(subject.save).to be(true)
      end
    end

    context 'when record already exists' do
      before do
        allow(crime_application).to receive(association_name).and_return(association_double)
      end

      it 'updates the record if it already exists' do
        expect(crime_application).not_to receive(build_method_name)

        expect(association_double).to receive(:update).with(
          expected_attributes
        ).and_return(true)

        expect(subject.save).to be(true)
      end
    end
  end
end

RSpec.shared_examples 'a multiparam date validation' do |options|
  let(:attribute_name) { options[:attribute_name] }

  before do
    subject.public_send("#{attribute_name}=", date)
  end

  context 'when day is invalid' do
    let(:date) { { 3 => 32, 2 => 12, 1 => 2020 } }

    it 'has a validation error on the field' do
      expect(subject).to_not be_valid
      expect(subject.errors.added?(attribute_name, :invalid_day)).to eq(true)
    end
  end

  context 'when day is missing' do
    let(:date) { { 2 => 12, 1 => 2020 } }

    it 'has a validation error on the field' do
      expect(subject).to_not be_valid
      expect(subject.errors.added?(attribute_name, :invalid_day)).to eq(true)
    end
  end

  context 'when month is invalid' do
    let(:date) { { 3 => 25, 2 => 13, 1 => 2020 } }

    it 'has a validation error on the field' do
      expect(subject).to_not be_valid
      expect(subject.errors.added?(attribute_name, :invalid_month)).to eq(true)
    end
  end

  context 'when month is missing' do
    let(:date) { { 3 => 25, 1 => 2020 } }

    it 'has a validation error on the field' do
      expect(subject).to_not be_valid
      expect(subject.errors.added?(attribute_name, :invalid_month)).to eq(true)
    end
  end

  context 'when year is invalid (too old)' do
    let(:date) { { 3 => 25, 2 => 12, 1 => 1919 } }

    it 'has a validation error on the field' do
      expect(subject).to_not be_valid
      expect(subject.errors.added?(attribute_name, :year_too_early)).to eq(true)
    end
  end

  context 'when year is invalid (too futuristic)' do
    let(:date) { { 3 => 25, 2 => 12, 1 => 2051 } }

    it 'has a validation error on the field' do
      expect(subject).to_not be_valid
      expect(subject.errors.added?(attribute_name, :year_too_late)).to eq(true)
    end
  end

  context 'when year is missing' do
    let(:date) { { 3 => 25, 2 => 12 } }

    it 'has a validation error on the field' do
      expect(subject).to_not be_valid
      expect(subject.errors.added?(attribute_name, :invalid_year)).to eq(true)
    end
  end

  context 'when date contains garbage values' do
    let(:date) { { 3 => 'foo', 2 => 2, 1 => 'bar' } }

    it 'has a validation error on the field' do
      expect(subject).to_not be_valid
      expect(subject.errors.added?(attribute_name, :invalid)).to eq(true)
    end
  end

  context 'when date is not valid (non-leap year)' do
    let(:date) { { 3 => 29, 2 => 2, 1 => 2021 } }

    it 'has a validation error on the field' do
      expect(subject).to_not be_valid
      expect(subject.errors.added?(attribute_name, :invalid)).to eq(true)
    end
  end

  context 'when date is in the future' do
    let(:date) { Date.tomorrow }

    # `false` is the validator default unless passing a different config
    if options.fetch(:allow_future, false)
      it 'allows future dates' do
        expect(subject).to be_valid
        expect(subject.errors.added?(attribute_name, :future_not_allowed)).to eq(false)
      end
    else
      it 'does not allow future dates' do
        expect(subject).to_not be_valid
        expect(subject.errors.added?(attribute_name, :future_not_allowed)).to eq(true)
      end
    end
  end

  context 'when date is in the past' do
    let(:date) { Date.yesterday }

    # `true` is the validator default unless passing a different config
    if options.fetch(:allow_past, true)
      it 'allows past dates' do
        expect(subject).to be_valid
        expect(subject.errors.added?(attribute_name, :past_not_allowed)).to eq(false)
      end
    else
      it 'does not allow past dates' do
        expect(subject).to_not be_valid
        expect(subject.errors.added?(attribute_name, :past_not_allowed)).to eq(true)
      end
    end
  end
end
