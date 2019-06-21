# -*- encoding: utf-8 -*-
require 'rubygems'
require 'mysql'
require "active_record"

config = YAML.load_file( './database.yml' )
ActiveRecord::Base.establish_connection(config["production"])



class User < ActiveRecord::Base

end
#select login,password ,youxiao_date  from users where youxiao_date > NOW();
users = User.find_by_sql("select *  from users where youxiao_date >= CURRENT_DATE() AND v2ray = '试用';")

str_head = <<"EOS"
{
        "log": {
                "access": "/var/log/v2ray/access.log",
                        "error": "/var/log/v2ray/error.log",
                        "loglevel": "error"
        },
                "inbounds": [
                {
                        "port": 10000,
                        "protocol": "vmess",
                        "settings": {
                                "clients": [
				{ "id": "0b25a77d-35e8-46f8-869f-094a9f3fcea1", "level": 1, "alterId": 233 },
EOS


str_foot = <<"EOS"
                                ]
                        },
                        "streamSettings": {
                                "network": "ws"
                        },
                        "sniffing": {
                                "enabled": true,
                                "destOverride": [
                                        "http",
                                "tls"
                                        ]
                        }
                }
        ],
                "outbounds": [
                {
                        "protocol": "freedom",
                        "settings": {}
                },
                {
                        "protocol": "blackhole",
                        "settings": {},
                        "tag": "blocked"
                },
                {
                        "protocol": "freedom",
                        "settings": {},
                        "tag": "direct"
                },
                {
                        "protocol": "mtproto",
                        "settings": {},
                        "tag": "tg-out"
                }
        //include_out_config
        //
        ],
                "dns": {
                        "server": [
                                "1.1.1.1",
                        "1.0.0.1",
                        "8.8.8.8",
                        "8.8.4.4",
                        "localhost"
                                ]
                },
                "routing": {
                        "domainStrategy": "IPOnDemand",
                        "rules": [
                        {
                                "type": "field",
                                "ip": [
                                        "0.0.0.0/8",
                                "10.0.0.0/8",
                                "100.64.0.0/10",
                                "127.0.0.0/8",
                                "169.254.0.0/16",
                                "172.16.0.0/12",
                                "192.0.0.0/24",
                                "192.0.2.0/24",
                                "192.168.0.0/16",
                                "198.18.0.0/15",
                                "198.51.100.0/24",
                                "203.0.113.0/24",
                                "::1/128",
                                "fc00::/7",
                                "fe80::/10"
                                        ],
                                "outboundTag": "blocked"
                        },
                        {
                                "type": "field",
                                "inboundTag": ["tg-in"],
                                "outboundTag": "tg-out"
                        },
                                {
                                        "type": "field",
                                        "protocol": [
                                                "bittorrent"
                                                ],
                                        "outboundTag": "blocked"
                                }
                        ]
                },
                "transport": {
                        "kcpSettings": {
                                "uplinkCapacity": 100,
                                "downlinkCapacity": 100,
                                "congestion": true
                        },
                        "sockopt": {
                                "tcpFastOpen": true
                        }
                }
}
EOS
str =""
users.each do |r|
  str << "{ \"id\": \"#{r.uuid}\", \"level\": 1, \"alterId\": 233 },\n"
end

str = str_head + str.sub(/(\,)\n$/,'') + str_foot
new_file_name = "config.json_" 
File.open(new_file_name, 'w') {|file|
	file.write str
}

old = IO.readlines("./config.json")
new = IO.readlines("./config.json_")
ActiveRecord::Base.connection_pool.release_connection
unless (old == new)
  puts "upload!\n"
  puts Time.now
  #h2
  system("cp /home/kembo/vpn_batch/config.json_ /home/kembo/vpn_batch/config.json")
  system("scp  -B /home/kembo/vpn_batch/config.json root@43.225.100.142:/etc/v2ray/config.json")
  system("ssh root@43.225.100.142  -f 'systemctl restart v2ray'")
  #T1
  system("scp  -B /home/kembo/vpn_batch/config.json root@153.128.31.138:/etc/v2ray/config.json")
  system("ssh root@153.128.31.138  -f 'systemctl restart v2ray'")
  #Singa
  system("scp  -B /home/kembo/vpn_batch/config.json_ root@45.32.110.116:/etc/v2ray/config.json")
  system("ssh root@45.32.110.116  -f 'systemctl restart v2ray'")
end

#system("scp chap-secrets root@49.212.142.41:/etc/ppp/")
