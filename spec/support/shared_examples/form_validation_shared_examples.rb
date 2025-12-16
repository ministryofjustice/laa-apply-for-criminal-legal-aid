RSpec.shared_examples 'a has-one-association form' do |options|
  let(:association_name) { options[:association_name] }
  let(:expected_attributes) { options[:expected_attributes] }
  let(:build_method_name) { :"build_#{association_name}" }

  let(:association_double) { associated_class_name.camelize.constantize.new }

  def associated_class_name
    reflection = CrimeApplication.reflect_on_association(association_name)

    case reflection
    when ActiveRecord::Reflection::HasOneReflection
      # For an `association_name` of `:applicant` it will return `applicant`
      reflection.name.to_s
    when ActiveRecord::Reflection::ThroughReflection
      # For an `association_name` of `:applicant_contact_details` it will return `contact_details`
      reflection.source_reflection_name.to_s
    else
      raise 'Unknown reflection. Shared examples may need adjustments.'
    end
  end

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
  let(:earliest_year) do
    options[:earliest_year] || MultiparamDateValidator::DEFAULT_OPTIONS[:earliest_year]
  end
  let(:latest_year) do
    options[:latest_year] || MultiparamDateValidator::DEFAULT_OPTIONS[:latest_year]
  end

  before do
    subject.public_send(:"#{attribute_name}=", date)
  end

  context 'when day is invalid' do
    let(:date) { { 3 => 32, 2 => 12, 1 => 2020 } }

    it 'has a validation error on the field' do
      expect(subject).not_to be_valid
      expect(subject.errors.added?(attribute_name, :invalid_day)).to be(true)
    end
  end

  context 'when day is missing' do
    let(:date) { { 2 => 12, 1 => 2020 } }

    it 'has a validation error on the field' do
      expect(subject).not_to be_valid
      expect(subject.errors.added?(attribute_name, :invalid_day)).to be(true)
    end
  end

  context 'when month is invalid' do
    let(:date) { { 3 => 25, 2 => 13, 1 => 2020 } }

    it 'has a validation error on the field' do
      expect(subject).not_to be_valid
      expect(subject.errors.added?(attribute_name, :invalid_month)).to be(true)
    end
  end

  context 'when month is missing' do
    let(:date) { { 3 => 25, 1 => 2020 } }

    it 'has a validation error on the field' do
      expect(subject).not_to be_valid
      expect(subject.errors.added?(attribute_name, :invalid_month)).to be(true)
    end
  end

  context 'when month is a full month name in English' do
    let(:date) { { 3 => 25, 2 => 'december', 1 => 2020 } }

    it 'allows the month value' do
      subject.validate
      expect(subject.errors.added?(attribute_name, :invalid_month)).to be(false)
    end
  end

  context 'when month is a full month name in Welsh' do
    let(:date) { { 3 => 25, 2 => 'rhagfyr', 1 => 2020 } }

    it 'allows the month value' do
      I18n.with_locale(:cy) do
        subject.validate
        expect(subject.errors.added?(attribute_name, :invalid_month)).to be(false)
      end
    end
  end

  context 'when month is an abbreviated month name in English' do
    let(:date) { { 3 => 25, 2 => 'dec', 1 => 2020 } }

    it 'allows the month value' do
      subject.validate
      expect(subject.errors.added?(attribute_name, :invalid_month)).to be(false)
    end
  end

  context 'when month is an abbreviated month name in Welsh' do
    let(:date) { { 3 => 25, 2 => 'rhag', 1 => 2020 } }

    it 'allows the month value' do
      I18n.with_locale(:cy) do
        subject.validate
        expect(subject.errors.added?(attribute_name, :invalid_month)).to be(false)
      end
    end
  end

  context 'when year is invalid (too old)' do
    let(:date) { { 3 => 25, 2 => 12, 1 => earliest_year - 1 } }

    it 'has a validation error on the field' do
      expect(subject).not_to be_valid
      expect(subject.errors.added?(attribute_name, :year_too_early)).to be(true)
    end
  end

  context 'when year is invalid (too futuristic)' do
    let(:date) { { 3 => 25, 2 => 12, 1 => latest_year + 1 } }

    it 'has a validation error on the field' do
      expect(subject).not_to be_valid
      expect(subject.errors.added?(attribute_name, :year_too_late)).to be(true)
    end
  end

  context 'when year is missing' do
    let(:date) { { 3 => 25, 2 => 12 } }

    it 'has a validation error on the field' do
      expect(subject).not_to be_valid
      expect(subject.errors.added?(attribute_name, :invalid_year)).to be(true)
    end
  end

  context 'when date contains garbage values' do
    let(:date) { { 3 => 'foo', 2 => 2, 1 => 'bar' } }

    it 'has a validation error on the field' do
      expect(subject).not_to be_valid
      expect(subject.errors.added?(attribute_name, :invalid)).to be(true)
    end
  end

  context 'when date is not valid (non-leap year)' do
    let(:date) { { 3 => 29, 2 => 2, 1 => 2021 } }

    it 'has a validation error on the field' do
      expect(subject).not_to be_valid
      expect(subject.errors.added?(attribute_name, :invalid)).to be(true)
    end
  end

  context 'when date is in the future' do
    let(:date) { Date.tomorrow }

    # `false` is the validator default unless passing a different config
    if options.fetch(:allow_future, false)
      it 'allows future dates' do
        subject.validate
        expect(subject.errors.added?(attribute_name, :future_not_allowed)).to be(false)
      end
    else
      it 'does not allow future dates' do
        subject.validate
        expect(subject.errors.added?(attribute_name, :future_not_allowed)).to be(true)
      end
    end
  end

  context 'when date is in the past' do
    let(:date) { Date.yesterday }

    # `true` is the validator default unless passing a different config
    if options.fetch(:allow_past, true)
      it 'allows past dates' do
        subject.validate
        expect(subject.errors.added?(attribute_name, :past_not_allowed)).to be(false)
      end
    else
      it 'does not allow past dates' do
        subject.validate
        expect(subject.errors.added?(attribute_name, :past_not_allowed)).to be(true)
      end
    end
  end
end
