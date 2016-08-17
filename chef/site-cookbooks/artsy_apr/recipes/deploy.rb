deploy_user = "deploy"
deploy_target = "/home/#{deploy_user}/current"
application_name = node[:application_name]
configuration = node["artsy"]["config"][application_name]

include_recipe "citadel::default"

secrets = citadel["#{node[:application_name]}/#{node['environment']}"]

deploy application_name do
  repo configuration["deployment"]["repo"]
  branch configuration["deployment"]["branch"]
  user deploy_user
  deploy_to "/home/#{deploy_user}"
  action :deploy
  ssh_wrapper "/home/deploy/wrap-ssh4git.sh"
  notifies :restart, "supervisor_service[#{application_name}]"
end

application_env = case node['environment']
when "production"
  "prod"
when "staging"
  "stage"
when "development"
  "dev"
end

environment = {
  "USER" => deploy_user,
  "HOME" => "/home/#{deploy_user}",
  "MIX_ENV" => application_env,
  "MIX_HOME" => "/home/deploy/.mix",
  "MIX_ARCHIVES" => "/home/deploy/.mix/archives",
  "HEX_HOME" => "/home/deploy/.hex"
}

execute "get-hex" do
  command "mix local.hex --force"
  user deploy_user
  environment environment
  cwd deploy_target
  not_if { ::File.directory?("/home/deploy/.hex") }
end

execute "get-rebar" do
  command "mix local.rebar --force"
  user deploy_user
  environment environment
  cwd deploy_target
  not_if { ::File.exist?("/home/deploy/.mix/rebar") }
end

execute "get-mix-deps" do
  command "mix deps.get"
  user deploy_user
  environment environment
  cwd deploy_target
end

runtime_environment = Hash.new
runtime_environment.merge! environment

unless configuration["environment"].nil?
  runtime_environment.merge! configuration["environment"]
end
unless secrets["application"]["environment"].nil?
  runtime_environment.merge! secrets["application"]["environment"]
end

execute "compile-mix-deps" do
  command "mix compile"
  user deploy_user
  environment runtime_environment
  cwd deploy_target
end

execute "install-npm-packages" do
  command "npm install"
  cwd deploy_target
end

execute "brunch-build" do
  command "node node_modules/brunch/bin/brunch build --production"
  user deploy_user
  cwd deploy_target
end

execute "phoenix-digest" do
  command "mix phoenix.digest"
  user deploy_user
  environment runtime_environment
  cwd deploy_target
end

command = 'mix phoenix.server'

supervisor_service application_name do
  user deploy_user
  directory deploy_target
  command command
  stdout_logfile "/var/log/supervisor/#{application_name}.out"
  stdout_logfile_maxbytes '50MB'
  stdout_logfile_backups 5
  stderr_logfile "/var/log/supervisor/#{application_name}.err"
  stderr_logfile_maxbytes '50MB'
  stderr_logfile_backups 5
  autorestart true
  environment runtime_environment
end
