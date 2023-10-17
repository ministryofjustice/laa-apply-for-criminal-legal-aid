# frozen_string_literal: true

require 'clamby'

def clamd_config_file
  filename = ENV.fetch('CLAMD_CONF_FILENAME', 'clamd.local.conf')
  File.join(File.dirname(__FILE__), '..', 'clamd', filename)
end

Clamby.configure(
  {
    check: false,
    daemonize: true,
    config_file: clamd_config_file,
    output_level: 'medium', # one of 'off', 'low', 'medium', 'high'
    fdpass: true,
    stream: true,
    error_clamscan_missing: true,
    error_clamscan_client_error: true,
    error_file_missing: true,
  }
)
