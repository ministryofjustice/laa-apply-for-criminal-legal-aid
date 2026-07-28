require 'rails_helper'

RSpec.describe 'steps/submission/shared/_section.html.erb', type: :view do
  subject(:render_partial) { render partial: 'steps/submission/shared/section', locals: { section: } }

  let(:section) do
    double(
      heading: nil,
      title: 'Files',
      editable?: true,
      change_path: '/applications/12345/steps/evidence/upload',
      answers: []
    )
  end

  it 'adds the section title to the accessible link name' do
    render_partial

    link = Capybara.string(rendered).find(
      'a[href="/applications/12345/steps/evidence/upload"]'
    )

    expect(link).to have_text('Change Files', exact: true)
    expect(link.find('.govuk-visually-hidden').text.strip).to eq('Files')
  end
end
