RSpec.shared_examples 'a deduction fieldset form' do |fieldset_class, partnered|
  subject { fieldset_class.new(arguments) }

  let(:arguments) do
    {
      crime_application: crime_application,
      record: employment,
      deduction_type: deduction_type
    }
  end

  let(:crime_application) {
    income = Income.new(
      partner_employment_status: partnered ? ['employed'] : [],
      employment_status: ['employed'],
    )
    CrimeApplication.new(income:)
  }
  let(:employment) {
    ownership_type = partnered ? OwnershipType::PARTNER.to_s : OwnershipType::APPLICANT.to_s
    Employment.create!(crime_application:, ownership_type:)
  }
  let(:deduction_type) { nil }

  describe 'validation' do
    context 'when the deduction type is income_tax' do
      let(:deduction_type) { 'income_tax' }

      it { is_expected.to validate_presence_of(:amount, :blank, 'Enter how much Income Tax gets deducted') }
      it { is_expected.to validate_presence_of(:frequency, :blank, 'Select how often the Income Tax gets deducted') }
    end

    context 'when the deduction type is national_insurance' do
      let(:deduction_type) { 'national_insurance' }

      it { is_expected.to validate_presence_of(:amount, :blank, 'Enter how much National Insurance gets deducted') }

      it {
        expect(subject).to validate_presence_of(:frequency, :blank,
                                                'Select how often the National Insurance gets deducted')
      }
    end

    context 'when the deduction type is other' do
      let(:deduction_type) { 'other' }

      it { is_expected.to validate_presence_of(:amount, :blank, 'Enter amount of other deductions') }

      it {
        expect(subject).to validate_presence_of(:frequency, :blank,
                                                'Select how often the other deductions get deducted')
      }

      it { is_expected.to validate_presence_of(:details, :blank, 'Enter details of other deductions') }
    end
  end
end
