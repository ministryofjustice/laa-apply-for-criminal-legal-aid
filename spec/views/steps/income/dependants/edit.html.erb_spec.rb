require 'rails_helper'

RSpec.describe 'steps/income/dependants/edit', type: :view do
  subject(:render_view) { render }

  let(:crime_application) { CrimeApplication.new(case: Case.new, income: Income.new) }
  let(:dependants_attributes) do
    {
      '0' => { 'age' => 5 },
      '1' => { 'age' => 10 },
    }
  end

  let(:form_object) do
    Steps::Income::DependantsForm.new(
      crime_application:,
      dependants_attributes:
    )
  end

  before do
    view.class.include StepsHelper
    assign(:form_object, form_object)
    allow(view).to receive_messages(
      current_crime_application: nil,
      current_form_object: nil
    )
    allow(controller).to receive(:controller_path).and_return('steps/income/dependants')
    stub_template 'layouts/_step_header.html.erb' => ''

    # step_form builds a URL from the current route, which requires a real request ID.
    # Stub it to call form_for with a fixed URL so form fields render without routing.
    without_partial_double_verification do
      allow(view).to receive(:step_form) do |record, opts = {}, &block|
        view.form_for(record, { url: '/stub', method: :put }.merge(opts || {}), &block)
      end
    end
  end

  describe 'age unit accessibility' do
    it 'links the first age input to its unit span via aria-describedby' do
      render_view

      expect(rendered).to have_css('input[aria-describedby~="dependant-age-unit-1"]')
    end

    it 'renders a visually-hidden unit span for the first dependant' do
      render_view

      expect(rendered).to have_css(
        '#dependant-age-unit-1.govuk-visually-hidden',
        text: 'years old'
      )
    end

    it 'links each age input to its own unique unit span' do
      render_view

      expect(rendered).to have_css('input[aria-describedby~="dependant-age-unit-1"]')
      expect(rendered).to have_css('input[aria-describedby~="dependant-age-unit-2"]')
    end

    it 'renders unique unit span IDs for each dependant' do
      render_view

      unit_ids = Capybara.string(rendered)
                         .all('[id^="dependant-age-unit-"]')
                         .pluck(:id)

      expect(unit_ids).to eq(unit_ids.uniq)
    end

    context 'when a dependant has a validation error' do
      let(:dependants_attributes) { { '0' => { 'age' => 999 } } }

      before { form_object.valid? }

      it 'preserves the error description alongside the unit description' do
        render_view

        document = Capybara.string(rendered)
        input = document.find('input[aria-describedby~="dependant-age-unit-1"]')
        error = document.find('.govuk-error-message')
        described_by_ids = input['aria-describedby'].split

        expect(described_by_ids).to include(
          'dependant-age-unit-1', error[:id]
        )
      end
    end
  end
end
