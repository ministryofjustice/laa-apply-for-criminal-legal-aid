'use strict';

// Mirrors app/lib/filename_sanitizer.rb.
//
// macOS stores a `/` typed in Finder as a `:` on the POSIX filesystem, and the
// browser uploads that POSIX name. A `:` (and various other characters) in the
// multipart `filename=` is rejected by the WAF (ModSecurity) before the request
// reaches Rails, so the upload silently fails. We sanitise the filename before
// it is sent so the WAF never sees an unsupported character.
//
// Keep only letters, numbers, spaces and a small set of safe punctuation
// (`. _ -`), replacing anything else with a hyphen.
const FALLBACK = 'file'

export default function sanitizeFilename(filename) {
  if (!filename) { return FALLBACK }

  const sanitized = filename
    .normalize('NFC')
    .replace(/[^\p{L}\p{N}._ -]/gu, '-')
    .replace(/\s+/g, ' ')
    .replace(/-+/g, '-')
    .replace(/^[\s.-]+/, '')
    .replace(/[\s-]+$/, '')

  return sanitized || FALLBACK
}
