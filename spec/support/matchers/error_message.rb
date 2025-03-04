RSpec::Matchers.define :have_error do |question, error|
  match do |page|
    has_summary_error = page.has_css?('.govuk-error-summary', text: error)

    form_group = page.find('label, legend', text: question)
                     .ancestor('.govuk-form-group', match: :first)

    has_question_error = form_group.has_css?('.govuk-error-message', text: error)

    has_summary_error && has_question_error
  end

  description do
    "renders an error message '#{error}' on '#{question}'"
  end

  failure_message do
    "Expected error message '#{error}' on '#{question}'"
  end
end

RSpec::Matchers.define :have_step_error do |error|
  match do |page|
    page.has_css?('.govuk-error-summary', text: error)
  end

  description do
    "renders step error message '#{error}'"
  end

  failure_message do
    "Expected step error '#{error}'"
  end
end

RSpec::Matchers.define :have_file_error do |filename, error|
  match do |page|
    document_row = page.find('span._uploaded_file__filename', text: filename)
                       .ancestor('.govuk-table__cell', match: :first)

    @actual_text = document_row.find('.govuk-error-message').text(:all)

    @actual_text[error]
  end

  description do
    "renders an error '#{error}' on file '#{filename}'"
  end

  failure_message do
    "Expected error '#{error}' on file '#{filename}' got '#{@actual_text}'"
  end
end

RSpec::Matchers.define :have_errors do |*question_errors|
  match do |page|
    question_errors.each_slice(2).each do |question, error|
      expect(page).to have_error(question, error)
    end
  end
end
