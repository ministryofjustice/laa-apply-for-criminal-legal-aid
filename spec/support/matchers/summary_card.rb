RSpec::Matchers.define :have_summary_row do |question, answer|
  match do |page|
    key = page.find('dt', text: question)
    @value = key.sibling('dd').text(normalize_ws: true)
    @value == answer
  end

  description do
    "renders a summary list row with question '#{question}' and answer '#{answer}'"
  end

  failure_message do |_object|
    "Expected answer to be '#{answer}, got '#{@value}'"
  end
end
