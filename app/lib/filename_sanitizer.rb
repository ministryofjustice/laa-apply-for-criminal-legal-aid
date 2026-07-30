# Sanitises a user-supplied filename so it can be uploaded safely.
#
# macOS stores a `/` typed in Finder as a `:` on the POSIX filesystem, and the
# browser uploads that POSIX name. A `:` (and various other characters) in the
# multipart `filename=` is rejected by the WAF (ModSecurity) before the request
# reaches Rails, so the upload silently fails.
#
# We keep only letters, numbers, spaces and a small set of safe punctuation
# (`. _ -`), replacing anything else with a hyphen. The same rules are mirrored
# client-side (see app/javascript/local/sanitize-filename.js) so the WAF never
# sees an unsupported character in the first place.
module FilenameSanitizer
  ALLOWED = /[^\p{L}\p{N}._ -]/
  FALLBACK = 'file'.freeze

  module_function

  def call(filename)
    return FALLBACK if filename.blank?

    sanitized = filename.to_s.unicode_normalize(:nfc)
                        .gsub(ALLOWED, '-')
                        .gsub(/\s+/, ' ')
                        .squeeze('-')
                        .gsub(/\A[\s.-]+/, '')
                        .gsub(/[\s-]+\z/, '')

    sanitized.presence || FALLBACK
  end
end
