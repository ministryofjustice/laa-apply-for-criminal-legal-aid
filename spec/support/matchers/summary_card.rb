RSpec::Matchers.define :have_summary_row do |question, answer|
  match do |page|
    key = page.find('dt', text: question, match: :prefer_exact)
    @value = key.sibling('dd').text(normalize_ws: true)
    @value == answer
  end

  description do
    "renders a summary list row with question '#{question}' and answer '#{answer}'"
  end

  failure_message do
    "Expected answer to be '#{answer}, got '#{@value}'"
  end
end

RSpec::Matchers.define :have_rows do |*rows|
  match do |card|
    rows.each_slice(2).each do |key, value|
      expect(card).to have_summary_row(key, value)
    end
  end
end
