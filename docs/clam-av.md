# Clam AV

Apply requires evidence files to be scanned for viruses. We use ClamAV CLI to do that.

See the general README for setup guide.

## Overview

The Apply ClamAV setup in the live services relies on pre-existing work by HMPPS - specifically their ready-made ClamAV image:

```
docker pull ghcr.io/ministryofjustice/hmpps-clamav-freshclammed:latest
docker run -p 3310:3310 --name clamav-server ghcr.io/ministryofjustice/hmpps-clamav-freshclammed
```

On staging and locally we're testing <https://github.com/ministryofjustice/clamav-mirror> and <https://github.com/ministryofjustice/clamav-docker>

## Troubleshooting

### Testing clamdscan availability on the deployed server

If you need to check whether the Clamdscan service is working as expected between Apply and the ClamAV containers:

1. Open a shell in one of the application hosts

2. Locate the appropriate Clamd environment configuration file (should be located in /config/clamd)

3. Perform the scan via CLI. For example in the `staging` environment:

```
touch ./my-example-file.txt
clamdscan -c config/clamd/clamd.staging.conf --stream --no-summary ./my-example-file.txt
```

### Setting up ClamAV locally

1. Pull the HMPPS docker containter and start it:

```
docker pull ghcr.io/ministryofjustice/hmpps-clamav-freshclammed:latest
docker run -p 3310:3310 --name clamav-server ghcr.io/ministryofjustice/hmpps-clamav-freshclammed
```

2. Create a new Ruby project with the following structure:

```
+--src
   |__ Gemfile
   |__ scan.rb
+--local-clam.conf

```

3. File contents:

```
# Gemfile
source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.2"

gem 'clamby'
gem 'shellwords'

# scan.rb
require 'clamby'
require 'tempfile'
require 'shellwords'

Clamby.configure({
  :check => false,
  :daemonize => true,
  :config_file => '/full/path/to/local-clam.conf',
  :error_clamscan_missing => true,
  :error_clamscan_client_error => false,
  :error_file_missing => true,
  :error_file_virus => false,
  :fdpass => false,
  :stream => true,
  :reload => false,
  :output_level => 'high', # one of 'off', 'low', 'medium', 'high'
  :executable_path_clamscan => 'clamscan',
  :executable_path_clamdscan => 'clamdscan',
  :executable_path_freshclam => 'freshclam',
})

file_to_scan = Tempfile.new('check-file.txt')
file_to_scan.write('HELLO CLAMAV!');
file_to_scan.rewind

begin
  response = Clamby.safe?(file_to_scan.path)
  puts "CLAMBY RESULT: #{response}"
ensure
  file_to_scan.close
end


# local-clam.conf
TCPAddr localhost
TCPSocket 3310
```

4. Run it

```
cd src && ruby scan.rb
```
