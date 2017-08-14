# Contributing to Aprb

This project is work of [many developers](https://github.com/artsy/aprb/graphs/contributors).

We accept [pull requests](https://github.com/artsy/aprb/pulls), and you may [propose features and discuss issues](https://github.com/artsy/aprb/issues).

In the examples below, substitute your GitHub username for `contributor` in URLs.

## Fork the Project

Fork the [project on GitHub](https://github.com/artsy/aprb) and check out your copy.

```
git clone https://github.com/contributor/aprb.git
cd aprb
git remote add upstream https://github.com/artsy/aprb.git
```

## Run Aprb

Install Elixir, see [installation](http://elixir-lang.org/install.html).

```
brew install elixir
```

Note: if you are using a `.env` file, you will probably want to prepend `dotenv` to each of the `mix` commands below.

Install dependencies:

``` 
mix deps.get
```

Create and migrate your database:

```
mix ecto.create
mix ecto.migrate
```

Start the app:

```sh
mix run --no-halt
# or, if you want to enable pry debugging
iex -S mix run --no-halt
```

Currently you need to VPN to an Artsy environment to get a feed of notifications.

You can `curl -v localhost:4000/slack -X POST` and get back something.

## Create a Topic Branch

Make sure your fork is up-to-date and create a topic branch for your feature or bug fix.

```
git checkout master
git pull upstream master
git checkout -b my-feature-branch
```

## Write Tests

Write tests for all new features and fixes. Run tests with `mix test`.

We definitely appreciate pull requests that highlight or reproduce a problem, even without a fix.

## Write Code

Implement your feature or bug fix.

## Commit Changes

Make sure git knows your name and email address:

```
git config --global user.name "Your Name"
git config --global user.email "contributor@example.com"
```

## Push

```
git push origin my-feature-branch
```

## Make a Pull Request

Go to https://github.com/contributor/aprb and select your feature branch.
Click the 'Pull Request' button and fill out the form. Pull requests are usually reviewed within a few days.

## Rebase

If you've been working on a change for a while, rebase with upstream/master.

```
git fetch upstream
git rebase upstream/master
git push origin my-feature-branch -f
```

## Check on Your Pull Request

Go back to your pull request after a few minutes and see whether it passed muster with Semaphore. Everything should look green, otherwise fix issues and amend your commit as described above.

## Be Patient

It's likely that your change will not be merged and that the nitpicky maintainers will ask you to do more, or fix seemingly benign problems. Hang on there!

## Thank You

Please do know that we really appreciate and value your time and work. We love you, really. <3
