# Cookbook development using Vagrant

In this directory:

`bundle install`

To test provisioning of the apr server:

- Install [Vagrant](https://www.vagrantup.com/downloads.html) and [Virtual Box](https://www.virtualbox.org/wiki/Downloads)

- Put your user AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY in your ~/.bash_profile. And source it (`source ~/.bash_profile`).  It should look something like:

```
export AWS_ACCESS_KEY_ID=ASDHA2365236ASDDAS
export AWS_SECRET_ACCESS_KEY=232tgsdfsSDG/sdge3wsd/FGF59
```

- Provision the apr Vagrant box with `vagrant up`

- Make changes to cookbooks and test with `vagrant provision`

# Upgrading cookbooks on OpsWorks

- Make changes to the artsy_apr cookbook

- Run `bundle exec rake ow:cookbooks:update[staging|production]` to vendor cookbooks to S3 for the given stack
