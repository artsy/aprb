remote_file "/tmp/erlang-solutions_1.0_all.deb" do
  source "https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb"
  notifies :run, 'execute[install-erlang-deb]', :immediately
end

execute "install-erlang-deb" do
  command "dpkg -i /tmp/erlang-solutions_1.0_all.deb"
  action :nothing
  notifies :run, 'execute[update-apt-erlang]', :immediately
end

execute "update-apt-erlang" do
  command "apt-get update"
  action :nothing
end

package "esl-erlang" do
  version node[:apr][:erlang_version]
end

package "elixir" do
  version node[:apr][:elixir_version]
end
