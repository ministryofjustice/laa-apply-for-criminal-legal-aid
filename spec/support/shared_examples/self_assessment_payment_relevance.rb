RSpec.shared_examples 'Self Assessment payment relevance' do |owner, employment_attribute|
  let(:question) { "#{owner}_self_assessment_tax_bill" }

  before do
    allow(MeansStatus).to receive_messages(full_means_required?: true, include_partner?: true)
    income.assign_attributes(
      employment_attribute => ['employed'],
      question => 'yes',
      "#{question}_amount" => 123_45,
      "#{question}_frequency" => 'month'
    )
  end

  it 'returns relevant payment details' do
    expect(income.public_send("#{question}_amount").to_i).to eq(123_45)
    expect(income.public_send("#{question}_frequency")).to eq('month')
  end

  it 'hides details when the answer changes to No and restores them for Yes' do
    income.public_send("#{question}=", 'no')
    expect(income.public_send("#{question}_amount")).to be_nil
    expect(income.public_send("#{question}_frequency")).to be_nil

    income.public_send("#{question}=", 'yes')
    expect(income.public_send("#{question}_amount").to_i).to eq(123_45)
    expect(income.public_send("#{question}_frequency")).to eq('month')
  end

  it 'hides details when the question is unanswered' do
    income.public_send("#{question}=", nil)
    expect(income.public_send("#{question}_amount")).to be_nil
    expect(income.public_send("#{question}_frequency")).to be_nil
  end

  it 'hides details when full means is no longer required' do
    allow(MeansStatus).to receive(:full_means_required?).and_return(false)
    expect(income.public_send("#{question}_amount")).to be_nil
    expect(income.public_send("#{question}_frequency")).to be_nil
  end

  it 'hides details when no longer working' do
    income.public_send("#{employment_attribute}=", ['not_working'])
    expect(income.public_send("#{question}_amount")).to be_nil
    expect(income.public_send("#{question}_frequency")).to be_nil
  end

  it 'returns payment details for self-employment' do
    income.public_send("#{employment_attribute}=", ['self_employed'])
    expect(income.public_send("#{question}_amount").to_i).to eq(123_45)
    expect(income.public_send("#{question}_frequency")).to eq('month')
  end

  if owner == :partner
    it 'hides details when the partner is excluded from means assessment' do
      allow(MeansStatus).to receive(:include_partner?).and_return(false)
      expect(income.public_send("#{question}_amount")).to be_nil
      expect(income.public_send("#{question}_frequency")).to be_nil
    end
  end
end
