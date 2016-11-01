confd --onetime --log-level debug --confdir /etc/confd --backend etcd --node $ETCD_URL --watch -keep-stage-file 
