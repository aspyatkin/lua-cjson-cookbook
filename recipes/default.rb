include_recipe 'build-essential'
include_recipe 'lua'

lua_cjson_tar_path = ::File.join Chef::Config['file_cache_path'], "lua-cjson-#{node['lua-cjson']['version']}.tar.gz"
lua_cjson_src_url = "#{node['lua-cjson']['url']}/#{node['lua-cjson']['version']}.tar.gz"
lua_cjson_src_dir = ::File.join Chef::Config['file_cache_path'], "lua-cjson-#{node['lua-cjson']['version']}"

remote_file lua_cjson_tar_path do
  source lua_cjson_src_url
  checksum node['lua-cjson']['checksum']
  mode 0644
end

directory lua_cjson_src_dir do
  action :create
end

makefile_path = ::File.join lua_cjson_src_dir, 'Makefile'

execute "tar --no-same-owner -zxf #{::File.basename lua_cjson_tar_path } -C #{lua_cjson_src_dir} --strip-components 1" do
  cwd Chef::Config['file_cache_path']
  creates makefile_path
end

cookbook_file 'patch Makefile' do
  path makefile_path
  source 'Makefile'
end

execute 'make install lua-cjson package' do
  environment({
    'PATH' => '/usr/local/bin:/usr/bin:/bin',
    'LUA_INCLUDE_DIR' => '/usr/include/lua5.1'
  })
  command 'make install'
  cwd lua_cjson_src_dir
  creates ::File.join(node['lua-cjson']['dir'], node['lua-cjson']['creates'])
end
