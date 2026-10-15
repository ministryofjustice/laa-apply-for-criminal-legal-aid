require 'rails_helper'

RSpec.describe 'Handling stolen goods offence choices', :authorized do
  include_context 'with office code selected'

  let(:crime_application) { CrimeApplication.create!(office_code: selected_office_code, case: Case.new) }
  let(:charge) { crime_application.case.charges.create! }
  let(:offence_classes) { %w[F G K] }
  let(:synonyms) { (['handling stolen goods, selling'] * 3) + (['handle stolen goods, buying'] * 3) }
  let(:names) do
    [
      'Handle stolen goods, selling (£30,000 or less)',
      'Handle stolen goods, selling (Over £30,000 up to £100,000)',
      'Handle stolen goods, selling (Over £100,000)',
      'Handling stolen goods, buying - Theft Act 1968 (£30,000 or less)',
      'Handling stolen goods, buying - Theft Act 1968 (Over £30,000 up to £100,000)',
      'Handling stolen goods, buying - Theft Act 1968 (Over £100,000)',
    ]
  end

  %i[en cy].each do |locale|
    context "in the #{locale} journey" do
      let(:captions) do
        offence_classes.map { |value| I18n.t('steps.shared.offence_class', class: value, locale: locale) } * 2
      end

      it 'offers only the six clarified English names, with searchable alternatives and class captions' do
        get edit_steps_case_charges_path(id: crime_application, charge_id: charge, locale: locale)

        expect(response).to have_http_status(:ok)
        options = response.parsed_body.css('datalist option').select do |option|
          option.text.include?('stolen goods')
        end
        expect(options.map(&:text)).to match_array(names)
        expect(options.pluck('data-caption')).to match_array(captions)
        expect(options.pluck('data-synonyms')).to match_array(synonyms)
      end
    end
  end

  bands = ['£30,000 or less', 'Over £30,000 up to £100,000', 'Over £100,000']
  [
    'Handle stolen goods, selling',
    'Handling stolen goods, buying - Theft Act 1968',
  ].each do |name|
    bands.each do |band|
      it "saves the selected wording for #{name} (#{band})" do
        put steps_case_charges_path(id: crime_application, charge_id: charge), params: {
          steps_case_charges_form: { offence_name: "#{name} (#{band})" },
        }

        expect(response).to have_http_status(:redirect)
        expect(charge.reload.offence_name).to eq("#{name} (#{band})")
      end
    end
  end
end
