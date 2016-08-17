#
# Cookbook Name:: artsy_apr
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "#{cookbook_name}::setup"
include_recipe "#{cookbook_name}::configure"
include_recipe "#{cookbook_name}::deploy"
