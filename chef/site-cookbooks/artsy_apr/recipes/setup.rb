include_recipe "artsy_base::default"

include_recipe "#{cookbook_name}::elixir"

include_recipe "nodejs::npm"

include_recipe "artsy_base::nginx"

cookbook_file "/etc/nginx/conf.d/apr-backend.conf" do
  mode "0644"
  notifies :reload, 'service[nginx]'
end
