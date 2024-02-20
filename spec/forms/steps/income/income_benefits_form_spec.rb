require 'rails_helper'

RSpec.describe Steps::Income::IncomeBenefitsForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      crime_application: crime_application,
      types: allowed_types,
    }
  end

  let(:crime_application) { CrimeApplication.new(case: case_record) }
  let(:case_record) { Case.new }

  let(:allowed_types) do
    %w[child working_or_child_tax_credit incapacity industrial_injuries_disablement jsa other]
  end

  let(:fieldset_form_class) { Steps::Income::IncomeBenefitFieldsetForm }

  let(:payments) do
    subject.crime_application.income_benefits
  end

  it_behaves_like 'a payment form', described_class

  describe '#save' do
    context 'with form submission' do
      subject do
        described_class.new(
          crime_application: crime_application,
          types: form_data.dig('steps_income_income_benefits_form', 'types'),
          income_benefits: form_data.dig('steps_income_income_benefits_form', 'income_benefits'),
        )
      end

      before do
        allowed_types.each do |type|
          subject.public_send("#{type}=", form_data.dig('steps_income_income_benefits_form', type))
        end

        subject.valid?
      end

      context 'with valid data' do
        let(:form_data) do
          {
            'steps_income_income_benefits_form' => {
              'income_benefits' => [''], # Rails nested attributes field
              'types' => %w[child jsa other], # Selected payment checkboxes

              'child' =>  { 'amount_in_pounds' => '56.12', 'frequency' => 'week' }, # Data for selected payment
              'working_or_child_tax_credit' => { 'amount_in_pounds' => '', 'frequency' => '' },
              'incapacity' => { 'amount_in_pounds' => '', 'frequency' => '' },
              'industrial_injuries_disablement' => { 'amount_in_pounds' => '', 'frequency' => '' },
              'jsa' => { 'amount_in_pounds' => '3.00', 'frequency' => 'annual' },
              'other' => { 'amount_in_pounds' => '44', 'frequency' => 'week', 'details' => 'Side hustle' },
            }
          }
        end

        it 'is valid' do
          expect(subject).to be_valid
        end
      end

      context 'with invalid data' do
        let(:form_data) do
          {
            'steps_income_income_benefits_form' => {
              'income_benefits' => [''],
              'types' => %w[child jsa other],

              'child' =>  { 'amount_in_pounds' => '', 'frequency' => 'every week' },
              'working_or_child_tax_credit' => { 'amount_in_pounds' => '', 'frequency' => '' },
              'incapacity' => { 'amount_in_pounds' => '', 'frequency' => '' },
              'industrial_injuries_disablement' => { 'amount_in_pounds' => '', 'frequency' => '' },
              'jsa' => { 'amount_in_pounds' => '3.00', 'frequency' => 'annual', 'details' => 'How?' },
              'other' => { 'amount_in_pounds' => '44', 'frequency' => 'week', 'details' => 'Side hustle' },
            }
          }
        end

        it 'is invalid' do
          expect(subject).not_to be_valid
        end

        it 'has error messages' do
          expect(subject.errors.of_kind?('child-amount_in_pounds', :greater_than)).to be(true)
          expect(subject.errors.of_kind?('child-frequency', :inclusion)).to be(true)
          expect(subject.errors.of_kind?('jsa-details', :invalid)).to be(true)

          # Error attributes should respond
          expect(subject.send(:'child-amount_in_pounds')).to eq '0.00'
        end
      end
    end
  end
end
