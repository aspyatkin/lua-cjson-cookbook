include_recipe 'build-essential'
include_recipe 'lua'
id = 'lua-cjson'

lua_cjson_tar_path = ::File.join Chef::Config[:file_cache_path], "lua-cjson-#{node[id][:version]}.tar.gz"
lua_cjson_src_url = "#{node[id][:url]}/#{node[id][:version]}.tar.gz"
lua_cjson_src_dir = ::File.join Chef::Config[:file_cache_path], "lua-cjson-#{node[id][:version]}"

remote_file lua_cjson_tar_path do
  source lua_cjson_src_url
  checksum node[id][:checksum]
  mode 0644
end

directory lua_cjson_src_dir do
  action :create
end

makefile_path = ::File.join lua_cjson_src_dir, 'Makefile'

execute "tar --no-same-owner -zxf #{::File.basename lua_cjson_tar_path } -C #{lua_cjson_src_dir} --strip-components 1" do
  cwd Chef::Config[:file_cache_path]
  creates makefile_path
end

# Patch Makefile
cookbook_file makefile_path do
  source 'Makefile'
end

execute 'make install lua-cjson package' do
  environment({
    'PATH' => '/usr/local/bin:/usr/bin:/bin',
    'LUA_INCLUDE_DIR' => '/usr/include/lua5.1'
  })
  command 'make install'
  cwd lua_cjson_src_dir
  creates ::File.join node[id][:dir], node[id][:creates]
end
