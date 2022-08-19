RSpec::Matchers.define :have_destination do |controller, action, params = {}|
  match do |decision_tree|
    decision_tree.destination[:controller] == controller &&
      decision_tree.destination[:action] == action &&
      params.key?(:id) &&
      params.keys.all? { |key| decision_tree.destination[key].to_s == params[key].to_s }
  end

  failure_message do |decision_tree|
    "expected decision tree destination to be an appropriately formatted hash, got '#{decision_tree.destination}'"
  end
end
