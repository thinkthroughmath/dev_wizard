# DevWizard

![Heroku](https://heroku-badge.herokuapp.com/?app=dev-wizard)
[![Stories in Ready](https://badge.waffle.io/thinkthroughmath/dev_wizard.png?label=ready&title=Ready)](https://waffle.io/thinkthroughmath/dev_wizard)
[![Build Status](https://travis-ci.org/thinkthroughmath/dev_wizard.svg?branch=master)](https://travis-ci.org/thinkthroughmath/dev_wizard)

DevWizard is an Elixir/Phoenix application to help automate our workflow.

## Setup

Instructions are written for setup and usage on Mac OSX, but should work on
other supported platforms as well.

## Run Locally

### Requirements/Dependencies

  1. Elixir: http://elixir-lang.org/
  2. Node.js: https://nodejs.org/en/
  3. Postgres: http://www.postgresql.org/

### Setup

  1. Install Elixir: `$ brew update && brew install elixir`
  2. Install dependencies: `$ mix deps.get`
  3. Create and migrate your database: `$ mix ecto.create && mix ecto.migrate`
  4. Create a file called `secret_vars.sh`. See section on `secret_vars.sh` for details.

  Note: You may have to run `$ npm install` when prompted.

#### secret_vars.sh

This file contains sensitive keys and should not be committed to source control.
This file is required to run the DevWizard. Create your own version with your
GitHub application keys.

The file should contain the following lines:

```
export DW_GH_CLIENT_ID=<YOUR GITHUB CLIENT ID>
export DW_GH_CLIENT_SECRET=<YOUR GITHUB CLIENT SECRET>
export DW_GH_ORGANIZATION=<YOUR GITHUB ORGANIZATION>
export DW_GH_REPOSITORIES=<YOUR GITHUB REPOSITORIES>
export DW_GH_STORYBOARD_REPO=<YOUR GITHUB STORYBOARD REPO>
```

Note: Replace `<...>` with your GitHub client ID and client secret key.

Note: You may need to setup these keys through GitHub.

For details, see: https://github.com/settings/applications/new

### Running

Start your Phoenix app endpoint: `$ ./run_development.sh`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Deploy

Automatic deploys are setup on Heroku for any push to the `master` branch, so
you may not need to do anything more than this to deploy. However, you can manually
deploy using the steps below, if required.

### Setup

  1. Install Heroku: `$ brew install heroku`
  2. `$ heroku login`
  3. `$ heroku git:remote -a dev-wizard`

### Deploying

  To deploy to production, run: `$ git push heroku master`

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: http://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
  * Deployment: http://www.phoenixframework.org/docs/deployment

# More

Ask in issues
