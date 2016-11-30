#cat /app/logstash/config/syslog.conf
input {
file {
type => "syslog"
path => ["/var/log/messages", "/var/log/secure" ]
exclude => ["*.gz"]
  }
syslog {
type => "syslog"
port => "5544"
  }
}
filter {
if [type] == "syslog" {
grok {
      match =>{ "message" => "%{SYSLOGTIMESTAMP:syslog_timestamp} %{SYSLOGHOST:syslog_hostname} %{DATA:syslog_program}(?:\[%{POSINT:syslog_pid}\])?: %{GREEDYDATA:syslog_message}" }
add_field =>[ "received_at", "%{@timestamp}" ]
add_field =>[ "received_from", "%{host}" ]
    }
date {
match => [ "syslog_timestamp", "MMM  d HH:mm:ss", "MMM ddHH:mm:ss" ]
    }
  }
}

output {
elasticsearch {
hosts => ["10.163.36.22" ]
user => "elastic"
password => ",ki89ol."
      index => "syslog-%{+YYYY.MM.dd.HH}"   --自定义index名称，需要与kibana创建索引时一致
 }
}
