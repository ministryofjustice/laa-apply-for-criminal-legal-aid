# laa-apply-for-criminal-legal-aid

[![CI and CD](https://github.com/ministryofjustice/laa-apply-for-criminal-legal-aid/actions/workflows/test-build-deploy.yml/badge.svg)](https://github.com/ministryofjustice/laa-apply-for-criminal-legal-aid/actions/workflows/test-build-deploy.yml)

A service to apply for criminal legal aid

## Getting Started

Clone the repository, and follow these steps in order.  
The instructions assume you have [Homebrew](https://brew.sh) installed in your machine, as well as use some ruby version manager, usually [rbenv](https://github.com/rbenv/rbenv). If not, please install all this first.

**1. Pre-requirements**

* `brew bundle`
* `gem install bundler`
* `bundle install`

**2. Configuration**

* Copy `.env.development` to `.env.development.local` and modify with suitable values for your local machine
* Copy `.env.test` to `.env.test.local` and modify with suitable values for your local machine

After you've defined your DB configuration in the above files, run the following:

* `bin/rails db:prepare` (for the development database)
* `RAILS_ENV=test bin/rails db:prepare` (for the test database)

**3. GOV.UK Frontend (styles, javascript and other assets)**

* `yarn`

**4. Run the app locally**

Once all the above is done, you should be able to run the application as follows:

a) `bin/dev` - will run foreman, spawning a rails server and `dartsass:watch` to process SCSS files and watch for any changes.  
b) `rails server` - will only run the rails server, usually fine if you are not making changes to the CSS.

You can also compile assets manually with `rails dartsass:build` at any time, and just run the rails server, without foreman.

If you ever feel something is not right with the CSS or JS, run `rails assets:clobber` to purge the local cache.

**Note about the datastore service**

Some functionality in this service relies on a [remote datastore](https://github.com/ministryofjustice/laa-criminal-applications-datastore) 
being available to submit applications, and read these back again.

Mainly, the service can be fully used without any external dependencies up until the submission point, where the datastore needs to be locally running 
to receive the submitted application.  
Also, some functionality in the dashboard will make use of this datastore.

For active development, and to debug or diagnose issues, running the datastore locally along the Apply application is 
the recommended way. Follow the instructions in the above repository to setup and run the datastore locally.

## Running the tests

You can run all the code linters and tests with:

* `rake`

The tasks run by default when using `rake`, are defined in the `Rakefile`.

Or you can run them individually:

* `rake spec`
* `rake erblint`
* `rake rubocop`
* `rake brakeman`

## Docker

The application can be run inside a docker container. This will take care of the ruby environment, postgres database 
and any other dependency for you, without having to configure anything in your machine.

* `docker-compose up`

The application will be run in "production" mode, so will be as accurate as possible to the real production environment.

**NOTE:** never use `docker-compose` for a real production environment. This is only provided to test a local container. The 
actual docker images used in the cluster are built as part of the deploy pipeline.


## Feature Flags

Feature flags can be set so that functionality can be enabled and disabled depending on the environment that the application is running in.

Set a new feature flag in the `config/settings.yml` under the heading `feature_flags` like so:

```yaml
# config/settings.yml
feature_flags:
  your_new_feature:
    local: true
    test: false
    staging: true
    production: false
```

If not declared, `local` and `test` environments will default to `true` (feature flag enabled).  
Any other envs, if not explicitly declared, will default to `false` (for instance `staging` or `production`).

To check if a feature is enabled / disabled and run code accordingly, use:

```ruby
FeatureFlags.your_new_feature.enabled?
FeatureFlags.your_new_feature.disabled?
```


## Settings

Similar to feature flags, the application can have settings. The same file `config/settings.yml` is used to define 
settings, and these are not environment-aware. If your setting is supposed to change depending on the 
environment (staging / production for example) then it probably belongs in the kubernetes `config_map` instead.

To read a setting, use:

```ruby
Settings.setting_name
```


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
# Encode:
echo -n "new-string" | base64

# Decode:
echo "bmV3LXN0cmluZw==" | base64 --decode
```

The `secrets.yml` manifest files are git-crypted so we can commit these to the repository. 
Follow the [instructions](https://user-guide.cloud-platform.service.justice.gov.uk/documentation/other-topics/git-crypt-setup.html#git-crypt) 
on how to setup `git-crypt` locally and ask any existing collaborator to add your GPG key to the repo to be able to read/write secrets.

In the deploy pipeline we use a symmetric key exported as a repository secret `GIT_CRYPT_KEY` and a 
[github action](https://github.com/marketplace/actions/github-action-to-unlock-git-crypt-secrets) to unlock the secrets 
and apply them automatically as part of each deploy.  

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
