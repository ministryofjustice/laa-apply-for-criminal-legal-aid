RSpec.shared_examples 'a Self Assessment question form' do |owner|
  subject(:form) { described_class.new(crime_application:, **{ question => answer }) }

  let(:question) { "#{owner}_self_assessment_tax_bill" }
  let(:answer) { 'yes' }
  let(:crime_application) { CrimeApplication.create!(income: Income.new) }

  it 'saves Yes without requiring payment details' do
    expect(form.save).to be(true)
    expect(crime_application.income.reload[question]).to eq('yes')
  end

  it 'does not change existing payment details when saving Yes' do
    income = crime_application.income
    income.update!("#{question}_amount" => 123_45, "#{question}_frequency" => 'month')

    expect(form.save).to be(true)
    expect(income.reload["#{question}_amount"].to_i).to eq(123_45)
    expect(income["#{question}_frequency"]).to eq('month')
  end

  context 'with no answer' do
    let(:answer) { nil }

    it 'requires a yes/no answer' do
      expect(form.save).to be(false)
      expect(form.errors.of_kind?(question, :inclusion)).to be(true)
    end
  end

  context 'with an invalid answer' do
    let(:answer) { 'maybe' }

    it { is_expected.not_to be_valid }
  end

  context 'when changing the answer to No' do
    let(:answer) { 'no' }

    it 'clears the stored payment details' do
      income = crime_application.income
      income.update!("#{question}_amount" => 123_45, "#{question}_frequency" => 'month')

      expect(form.save).to be(true)
      expect(income.reload[question]).to eq('no')
      expect(income["#{question}_amount"]).to be_nil
      expect(income["#{question}_frequency"]).to be_nil
    end

    it 'also clears payment details when saving a draft' do
      income = crime_application.income
      income.update!("#{question}_amount" => 123_45, "#{question}_frequency" => 'month')

      expect(form.save!).to be(true)
      expect(income.reload["#{question}_amount"]).to be_nil
      expect(income["#{question}_frequency"]).to be_nil
    end
  end

  it 'allows saving an unanswered draft' do
    income = crime_application.income
    income.update!("#{question}_amount" => 123_45, "#{question}_frequency" => 'month')
    form.public_send("#{question}=", nil)

    expect(form.save!).to be(true)
    expect(income.reload["#{question}_amount"]).to be_nil
    expect(income["#{question}_frequency"]).to be_nil
  end
end

RSpec.shared_examples 'a Self Assessment payment form' do |owner|
  subject(:form) do
    described_class.new(
      :crime_application => crime_application,
      "#{owner}_self_assessment_tax_bill_amount" => amount,
      "#{owner}_self_assessment_tax_bill_frequency" => frequency
    )
  end

  let(:crime_application) { CrimeApplication.create!(income: Income.new) }
  let(:amount) { '123.45' }
  let(:frequency) { 'month' }

  it 'persists the amount in pence and the frequency' do
    expect(form.save).to be(true)
    income = crime_application.income.reload
    expect(income["#{owner}_self_assessment_tax_bill_amount"].to_i).to eq(123_45)
    expect(income["#{owner}_self_assessment_tax_bill_frequency"]).to eq('month')
  end

  context 'with a zero amount' do
    let(:amount) { '0' }

    it { is_expected.to be_valid }
  end

  context 'with a negative amount' do
    let(:amount) { '-1' }

    it { is_expected.not_to be_valid }
  end

  context 'without an amount' do
    let(:amount) { nil }

    it 'requires an amount' do
      expect(form.save).to be(false)
      expect(form.errors.of_kind?("#{owner}_self_assessment_tax_bill_amount", :not_a_number)).to be(true)
    end
  end

  context 'with a non-numeric amount' do
    let(:amount) { 'invalid' }

    it { is_expected.not_to be_valid }
  end

  context 'without a frequency' do
    let(:frequency) { nil }

    it { is_expected.not_to be_valid }
  end

  context 'with an invalid frequency' do
    let(:frequency) { 'every six weeks' }

    it { is_expected.not_to be_valid }
  end

  context 'when saving an incomplete draft' do
    let(:frequency) { nil }

    it 'saves without validation' do
      expect(form.save!).to be(true)
      expect(crime_application.income.reload["#{owner}_self_assessment_tax_bill_amount"].to_i).to eq(123_45)
    end
  end
end
