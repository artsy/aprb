# Aprb

Artsy Public Radio notifications in Slack.

<img src='apr.png' width='75'>

Aprb is a fairly generic consumer of Kafka events (see [Aprb.EventReceiver](lib/event_receiver.ex) that uses [kafka_ex](https://github.com/kafkaex/kafka_ex)), producer of Slack messages (see [Aprb.Service.EventService](lib/services/event_service.ex) that uses [elixir-slack](https://github.com/BlakeWilliams/Elixir-Slack)) and a command-and-control Slack slash command API endpoint (see [Aprb.Service.SlackCommandService](lib/services/slack_command_service.ex) and [Aprb.Api.Root](lib/api/root.ex) that uses [maru](https://github.com/falood/maru)). Users can subscribe to topics from Slack with `/apr subscribe`. Subscriptions are backed by a PostgreSQL database (see [Aprb.Subscription](lib/models/subscription.ex) that uses [ecto](https://github.com/elixir-ecto/ecto)). Aprb was written in Elixir during the Artsy Hackathon 2016.

## Meta

[![Build Status](https://travis-ci.org/artsy/aprb.svg?branch=master)](https://travis-ci.org/artsy/aprb)

* __State:__ production
* __Production:__ [http://aprb-production-http-1702133716.us-east-1.elb.amazonaws.com/slack](http://aprb-production-http-1702133716.us-east-1.elb.amazonaws.com/slack)
* __Github:__ [https://github.com/artsy/aprb](https://github.com/artsy/aprb)
* __CI:__ [Travis-CI](https://travis-ci.org/artsy/aprb); production is manually deployed from OpsWorks
* __Point People:__ [@ashkan18](https://github.com/ashkan18), [@dblock](https://github.com/dblock)

## Work at Artsy?

If you work at Artsy, you can add events to Gravity (eg. [#10292](https://github.com/artsy/gravity/pull/10292)) and then receive and dispatch these in Aprb (eg. [#17](https://github.com/artsy/aprb/pull/17)). See [CONTRIBUTING](CONTRIBUTING.md) for how to run this project. If you don't work at Artsy, we hope this is a useful demo, feel free to build on top of it.

Don't know what Artsy is? Check out [this overview](https://github.com/artsy/meta/blob/master/meta/what_is_artsy.md) and [more](https://github.com/artsy/meta/blob/master/README.md). Want to know more about Artsy tech? Read the [Artsy Engineering Blog](http://artsy.github.io).

## LICENSE

Copyright (c) 2016 Artsy Inc.

MIT License, see [LICENSE](LICENSE).
