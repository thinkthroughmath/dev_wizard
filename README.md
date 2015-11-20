# DevWizard

## Setup

Install Elixir: `$ brew install elixir`

## Run Locally

To start your Phoenix app:

  1. Install dependencies with `mix deps.get`
  2. Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  3. Create a file called `secret_vars.sh`. See section on secret_vars.sh.
  4. Start Phoenix endpoint with `./run_development.sh`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

### secret_vars.sh

This file contains sensitive keys and should not be committed. Create your own
with GitHub application keys.

The file should look like this:

```
export GH_CLIENT_ID=<YOUR GITHUB CLIENT ID>
export GH_CLIENT_SECRET=<YOUR GITHUB CLIENT SECRET>
```

## Deploy

  * Install Heroku: `$ brew install heroku`
  * `$ heroku login`
  * `$ heroku git:remote -a dev-wizard`
  * `$ git push heroku master`

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: http://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
  * Deployment: http://www.phoenixframework.org/docs/deployment
