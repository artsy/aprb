deploy_user = "deploy"

directory "/home/#{deploy_user}/.ssh" do
  owner deploy_user
  recursive true
end

include_recipe "citadel::default"

file "/home/#{deploy_user}/.ssh/deploy_key" do
  content citadel["#{node[:application_name]}/deploy_key"]
  owner deploy_user
  mode '0600'
end

cookbook_file "/home/#{deploy_user}/wrap-ssh4git.sh" do
  source 'wrap-ssh4git.sh'
  owner deploy_user
  mode '0755'
end

package "git"
