RSpec.shared_examples 'a Self Assessment payment controller' do |person, owner, form_class|
  include_context 'current provider with active office'

  let(:answer) { 'yes' }
  let(:income) do
    Income.new(employment_status: ['employed'], partner_employment_status: ['employed']).tap do |record|
      record.public_send("#{owner}_self_assessment_tax_bill=", answer)
    end
  end
  let(:existing_case) do
    CrimeApplication.create!(
      office_code: office_code,
      applicant: Applicant.new,
      partner: Partner.new,
      partner_detail: PartnerDetail.new(involvement_in_case: 'none'),
      income: income
    )
  end

  before do
    allow(MeansStatus).to receive_messages(full_means_required?: true, include_partner?: true)
  end

  it_behaves_like 'a generic step controller', form_class, Decisions::IncomeDecisionTree

  shared_examples 'rejects access to Self Assessment payments' do
    let(:question_path) do
      public_send("edit_steps_income_#{person}_self_assessment_tax_bill_path", id: existing_case)
    end

    it 'redirects a direct page visit to the yes/no question' do
      get :edit, params: { id: existing_case }

      expect(response).to redirect_to(question_path)
    end

    it 'does not persist a direct payment submission' do
      expect(form_class).not_to receive(:new)

      put :update, params: { id: existing_case }.merge(
        form_class.model_name.singular => {
          "#{owner}_self_assessment_tax_bill_amount" => '123.45',
          "#{owner}_self_assessment_tax_bill_frequency" => 'month'
        }
      )

      expect(response).to redirect_to(question_path)
      expect(existing_case.income&.reload&.read_attribute("#{owner}_self_assessment_tax_bill_amount")).to be_nil
    end

    it 'rejects a direct draft save' do
      expect(form_class).not_to receive(:new)

      put :update, params: { id: existing_case, commit_draft: '' }

      expect(response).to redirect_to(question_path)
    end
  end

  context 'when the answer is No' do
    let(:answer) { 'no' }

    it_behaves_like 'rejects access to Self Assessment payments'
  end

  context 'when the question is unanswered' do
    let(:answer) { nil }

    it_behaves_like 'rejects access to Self Assessment payments'
  end

  context 'when there is no income record' do
    let(:income) { nil }

    it_behaves_like 'rejects access to Self Assessment payments'
  end
end
