# Aprb

Artsy Public Radio notifications in Slack.

<img src='apr.png' width='75'>

Aprb is a fairly generic consumer of RabbitMQ events (see [Service.AmqEventService](lib/services/amq_event_Service.ex) that uses [amqp_client](https://github.com/jbrisbin/amqp_client.git)), producer of Slack messages (see [Aprb.Service.EventService](lib/services/event_service.ex) that uses [elixir-slack](https://github.com/BlakeWilliams/Elixir-Slack)) and a command-and-control Slack slash command API endpoint (see [Aprb.Service.SlackCommandService](lib/services/slack_command_service.ex) and [Aprb.Api.Root](lib/api/root.ex) that uses [maru](https://github.com/falood/maru)). Users can subscribe to topics from Slack with `/apr subscribe`. Subscriptions are backed by a PostgreSQL database (see [Aprb.Subscription](lib/models/subscription.ex) that uses [ecto](https://github.com/elixir-ecto/ecto)). Aprb was written in Elixir during the Artsy Hackathon 2016.

## Meta

[![CircleCI](https://circleci.com/gh/artsy/aprb.svg?style=svg)](https://circleci.com/gh/artsy/aprb)

* __State:__ production
* __Production:__ [http://aprb-production-http-1702133716.us-east-1.elb.amazonaws.com/slack](http://aprb-production-http-1702133716.us-east-1.elb.amazonaws.com/slack)
* __GitHub:__ [https://github.com/artsy/aprb](https://github.com/artsy/aprb)
* __CI/Deploys:__ [CircleCi](https://circleci.com/gh/artsy/aprb); merged PRs to `artsy/aprb#master` are automatically deployed to staging; PRs from `staging` to `release` are automatically deployed to production. [Start a deploy...](https://github.com/artsy/aprb/compare/release...staging?expand=1)
* __Point People:__ [@ashkan18](https://github.com/ashkan18)

## Development

See [CONTRIBUTING](CONTRIBUTING.md) for instructions on bootstrapping and running the project.

## Work at Artsy?

If you work at Artsy, you can add events to Gravity (eg. [#10292](https://github.com/artsy/gravity/pull/10292)) and then receive and dispatch these in Aprb (eg. [#17](https://github.com/artsy/aprb/pull/17)). See [CONTRIBUTING](CONTRIBUTING.md) for how to run this project. If you don't work at Artsy, we hope this is a useful demo, feel free to build on top of it.

Don't know what Artsy is? Check out [this overview](https://github.com/artsy/meta/blob/master/meta/what_is_artsy.md) and [more](https://github.com/artsy/meta/blob/master/README.md). Want to know more about Artsy tech? Read the [Artsy Engineering Blog](http://artsy.github.io).

## LICENSE

Copyright (c) 2017 Artsy Inc.

MIT License, see [LICENSE](LICENSE).
