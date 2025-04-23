# Clam AV

Apply requires evidence files to be scanned for viruses. We use ClamAV CLI to do that.

See the general README for setup guide.

## Overview

The Apply ClamAV setup uses <https://github.com/ministryofjustice/clamav-mirror> and <https://github.com/ministryofjustice/clamav-docker>

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
