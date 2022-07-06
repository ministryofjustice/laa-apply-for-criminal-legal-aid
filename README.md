# laa-apply-for-criminal-legal-aid

[![CI and CD](https://github.com/ministryofjustice/laa-apply-for-criminal-legal-aid/actions/workflows/test-build-deploy.yml/badge.svg)](https://github.com/ministryofjustice/laa-apply-for-criminal-legal-aid/actions/workflows/test-build-deploy.yml)

A service to apply for criminal legal aid


## Docker

The application can be run inside a docker container. This will take care of the ruby environment, postgres database 
and any other dependency for you, without having to configure anything in your machine.

* `docker-compose up`

The application will be run in "production" mode, so will be as accurate as possible to the real production environment.

**NOTE:** never use `docker-compose` for a real production environment. This is only provided to test a local container. The 
actual docker images used in the cluster are built as part of the deploy pipeline.


## Kubernetes deployment

### To provision infrastructure

AWS infrastructure is created by Cloud Platforms via PR to [their repository](https://github.com/ministryofjustice/cloud-platform-environments).  
Read [how to connect the cluster](https://user-guide.cloud-platform.service.justice.gov.uk/documentation/getting-started/kubectl-config.html).

**Namespaces for this service:**
* [staging namespace](https://github.com/ministryofjustice/cloud-platform-environments/tree/main/namespaces/live.cloud-platform.service.justice.gov.uk/laa-apply-for-criminal-legal-aid-staging)
* [production namespace](https://github.com/ministryofjustice/cloud-platform-environments/tree/main/namespaces/live.cloud-platform.service.justice.gov.uk/laa-apply-for-criminal-legal-aid-prod) (not yet used)

### Encode secrets in Base64

When dealing with secrets, they need to be encoded in Base64, do not use online services for this.

```bash
# Encode:
echo -n "new-string" | base64

# Decode:
echo "bmV3LXN0cmluZw==" | base64 --decode
```

### Applying the configuration

Configuration is applied automatically as part of each deploy. You can also apply configuration manually, for example:

```bash
kubectl apply -f config/kubernetes/staging/ingress.yml
```

### Continuous integration and delivery

The application is setup to trigger tests on every pull request and, in addition, to build and release to staging 
automatically on merge to `main` branch. Release to production will need to be approved manually.

All this is done through **github actions**.

The secrets needed for these actions are created automatically as part of the **terraforming**. You can read more about 
it in [this document](https://user-guide.cloud-platform.service.justice.gov.uk/documentation/deploying-an-app/github-actions-continuous-deployment.html#automating-the-deployment-process).


## Architectural decision records

ADRs are in the `./docs/architectural-decisions/` folder will hold markdown documents that record Architectural decision records (ARDs) for the LAA Apply for Criminal Legal Aid application.

Please install [ADRs Tools](https://github.com/npryce/adr-tools) (`brew install adr-tools`) to help manage the creation of new ADR documents.

### To create a new ADR

After installing ADR tools use:

```
adr new <your ADR title>
```

This will initialise new blank ADR with your title as a heading and increment the ARD prefix to the correct number on the ARDs file name.

### Further info

For information on what ARDs are see [here](https://adr.github.io/).

