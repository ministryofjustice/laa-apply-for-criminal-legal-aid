RSpec::Matchers.define :validate_presence_of do |attribute, error = :blank, msg = nil|
  include ValidationHelpers

  match do |object|
    object.send(:"#{attribute}=", '')
    check_errors(object, attribute, error)

    return true if check_errors(object, attribute, error) && msg.nil?

    object.errors.full_messages_for(attribute).include? msg
  end

  chain :on_context, :validation_context

  description do
    "validate_presence_of #{attribute}"
  end

  failure_message do |object|
    if msg
      "expected `#{attribute}` to have error `#{error}` with message `#{msg}` \
      but got errors `#{errors_for(attribute, object)}` with messages \
      `#{object.errors.full_messages_for(attribute)}`"
    else
      "expected `#{attribute}` to have error `#{error}` but got `#{errors_for(attribute, object)}`"
    end
  end

  failure_message_when_negated do |object|
    "expected `#{attribute}` not to have error `#{error}` but got `#{errors_for(attribute, object)}`"
  end
end

RSpec::Matchers.define :validate_absence_of do |attribute, error = :present|
  include ValidationHelpers

  match do |object|
    object.send(:"#{attribute}=", 'xxx')
    check_errors(object, attribute, error)
  end

  chain :on_context, :validation_context

  description do
    "validate_absence_of #{attribute}"
  end

  failure_message do |object|
    "expected `#{attribute}` to have error `#{error}` but got `#{errors_for(attribute, object)}`"
  end

  failure_message_when_negated do |object|
    "expected `#{attribute}` not to have error `#{error}` but got `#{errors_for(attribute, object)}`"
  end
end

RSpec::Matchers.define :validate_is_a do |attribute, klass|
  include ValidationHelpers

  match do |object|
    value = klass.values.sample.to_s
    object.send(:"#{attribute}=", value)
    return false if check_errors(object, attribute, :inclusion)

    object.send(:"#{attribute}=", nil)
    return false unless check_errors(object, attribute, :inclusion)

    object.send(:"#{attribute}=", 'not_a_type')
    check_errors(object, attribute, :inclusion)
  end

  chain :on_context, :validation_context

  description do
    "validate #{attribute} is a #{klass}"
  end

  failure_message do |_object|
    "expected `#{attribute}` to have an error unless #{klass}"
  end

  failure_message_when_negated do |_object|
    "expected `#{attribute}` not to have an error unless #{klass}"
  end
end
