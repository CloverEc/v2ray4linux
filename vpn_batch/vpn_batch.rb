# -*- encoding: utf-8 -*-
require 'rubygems'
require 'mysql'
require "active_record"

########ActiveRecord::Base.establish_connection(
######## :adapter =>  'mysql',
######## :encoding =>  'utf8', 
######## :host => 'localhost',
######## :username => 'root',
######## :database => 'vpn_fast06_production',
######## :password => 'psswordPASSWORD@999'
########)
config = YAML.load_file( './database.yml' )
ActiveRecord::Base.establish_connection(config["production"])



class User < ActiveRecord::Base

end
#select login,password ,youxiao_date  from users where youxiao_date > NOW();
users = User.find_by_sql("select *  from users where youxiao_date >= CURRENT_DATE();")

str_head = <<"EOS"
{
   "server": "0.0.0.0",
   "local_address": "127.0.0.1",
   "local_port": 1080,
   "port_password": {
EOS


str_foot = <<"EOS"
   },
   "timeout": 300,
   "method": "aes-256-cfb",
   "fast_open": false
}
EOS

str =""
users.each do |r|
  str <<"	\"#{r.port}\": \"#{r.password}\",\n"
end

str = str_head + str.sub(/(\,)\n$/,'') + str_foot
new_file_name = "shadowsocks.json_" 
File.open(new_file_name, 'w') {|file|
	file.write str
}

old = IO.readlines("./shadowsocks.json")
new = IO.readlines("./shadowsocks.json_")
ActiveRecord::Base.connection_pool.release_connection
unless (old == new)
  puts "upload!\n"
  puts Time.now
  system("cp /home/kembo/vpn_batch/shadowsocks.json_ /home/kembo/vpn_batch/shadowsocks.json")
  system("scp  -B /home/kembo/vpn_batch/shadowsocks.json root@118.27.20.223:/etc/")
  system("ssh root@118.27.20.223   -f 'systemctl restart shadowsocks.service'")

  system("scp  -B /home/kembo/vpn_batch/shadowsocks.json root@118.27.37.223:/etc/")
  system("ssh root@118.27.37.223   -f 'systemctl restart shadowsocks.service'")

  system("scp  -B /home/kembo/vpn_batch/shadowsocks.json root@118.27.5.64:/etc/")
  system("ssh root@118.27.5.64   -f 'systemctl restart shadowsocks.service'")

  system("scp  -B /home/kembo/vpn_batch/shadowsocks.json root@118.27.34.43:/etc/")
  system("ssh root@118.27.34.43   -f 'systemctl restart shadowsocks.service'")
end

#system("scp chap-secrets root@49.212.142.41:/etc/ppp/")
