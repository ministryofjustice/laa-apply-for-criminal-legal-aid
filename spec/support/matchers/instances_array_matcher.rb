RSpec::Matchers.define :match_instances_array do |expected_array|
  match do |actual_array|
    actual_array.size == expected_array.size &&
      actual_array.map.with_index { |element, index| element.is_a?(expected_array[index]) }.all?
  end

  description do
    "match_instances_array #{expected_array}"
  end

  failure_message do |actual_array|
    "expected array `#{expected_array}` to match `#{actual_array}`"
  end
end
