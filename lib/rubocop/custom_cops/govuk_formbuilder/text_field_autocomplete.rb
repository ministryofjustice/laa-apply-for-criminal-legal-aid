module RuboCop
  module CustomCops
    module GOVUKFormBuilder
      # `govuk_text_field` has an explicit autocomplete attribute (on or off)`
      #
      # @example
      #   # bad
      #   f.govuk_text_field :field_name
      #
      #   # good
      #   f.govuk_text_field :field_name, autocomplete: 'off'
      #
      class TextFieldAutocomplete < RuboCop::Cop::Base
        MSG = 'Add an explicit `autocomplete: \'on|off\'` to `govuk_text_field` inputs.'.freeze

        def_node_matcher :has_autocomplete_attribute?, <<~PATTERN
          (send _ :govuk_text_field sym (hash <(pair (sym :autocomplete) {(str "on") | (str "off")}) ...>))
        PATTERN

        # Optimization: don't call `on_send` unless the method name is in this list
        RESTRICT_ON_SEND = [:govuk_text_field].freeze

        def on_send(node)
          return if has_autocomplete_attribute?(node)

          add_offense(node)
        end
      end
    end
  end
end
