# <span style="color: green">&#x1F535; Elastic Certified Engineer </span>

### <span style="color: green">&#x1F535; Configure  ELK on master  </span>

vi elasticsearch/config/elasticsearch.yml

```
--------------Cluster-------------
cluster.name: c1

--------------Node-------------
node.name: server1
node.attr.zone: 1

--------------Network-------------
network.host: ["172.42.42.101"]

#network.host: [_local_, _site_]

--------------Discovery-------------

cluster.initial_master_nodes: ["server1"]

--------------Various-------------

node.master: true
node.data: false
node.ingest: false
xpack.ml.enabled: false
```
nano config/jvm.options

```
-Xms768m
-Xms768m
```

### <span style="color: green">&#x1F535; Configure ELK on node 1  </span>

nano config/elasticsearch.yml

```
cluster.name: c1
node.name: server2
node.attr.zone: 1
node.attr.temp: hot
network.host: ["172.42.42.102"]
# the master private ip
discovery.seed_hosts: ["172.42.42.101"]
cluster.initial_master_nodes: ["server1"]

--------------Various-------------

node.master: false
node.data: true
node.ingest: false
xpack.ml.enabled: false

```

### <span style="color: green">&#x1F535; Configure ELK on nodes 2  </span>

nano config/elasticsearch.yml

```
cluster.name: c1
node.name: server3
node.attr.zone: 2
node.attr.temp: warm

network.host: ["172.42.42.103"]
#network.host: [_local_, _site_]

# the master private ip
discovery.seed_hosts: ["172.42.42.101"]
cluster.initial_master_nodes: ["server1"]

--------------Various-------------

node.master: false
node.data: true
node.ingest: false
xpack.ml.enabled: false


```
### <span style="color: green">&#x1F535; Install ELK on all nodes  </span>

./bin/elasticsearch -d -p pid
cat logs/c1.log
curl 172.42.42.101:9200/_cat/nodes?v

### If the installations has successfully done

```
curl 172.42.42.101:9200/_cat/nodes?v  

ip            heap.percent ram.percent cpu load_1m load_5m load_15m node.role master name
172.42.42.103            7          94  17    0.27    0.47     0.39 d         -      server3
172.42.42.102            7          93   5    0.00    0.10     0.15 d         -      server2
172.42.42.101           10          93   1    0.00    0.03     0.05 m         *      server1

```
# <span style="color: green">&#x1F535; Kibana </span>

vi config/kibana.yml

```
server.port: 80
server.host: "172.42.42.101"
elasticsearch.host: "172.42.42.101:9200"
```
### Change user to root and execute

```
/home/elastic/kibana/bin/kibana --allow-root
```

# <span style="color: green">&#x1F535; Kibana ui </span>



> console

```
GET _cat/nodes?v
```

# <span style="color: green">&#x1F535; Install the second elk cluster </span>

vi config/elasticsearch.yml

```
cluster.name: c2
node.name: server4
network.host: [_local_, _site_]
# the master private ip
cluster.initial_master_nodes: ["server4"]

--------------Various-------------

node.master: true
node.data: true
node.ingest: true
xpack.ml.enabled: false
```
### Check installing

```
./bin/elasticsearch -d -p pid

cat logs/c2.log
curl <ip>:9200
curl <ip>:9200/_cat/nodes?v
```

### Kibana Configure

vi config/kibana.yml

```
server.port: 80
server.host: <ip>
elasticsearch.host: "<ip>:9200"
```

### Change user to root and execute

```
/home/elastic/kibana/bin/kibana --allow-root

or  you can ran as a deamon
/home/elastic/kibana/bin/kibana --allow-root &
```

### Go to Kibana and check it

```
GET _cat/nodes?v
```


# <span style="color: green">&#x1F535; Secure ELK </span>

### Create the certs folder on all nodes

```
su - elastic
cd /home/elastic/elasticsearch
mkdir config/certs
cd config/certs
```

### On master node create certificate

```
/home/elastic/elasticsearch/bin/elasticsearch-certutil ca --out config/certs/ca --pass elastic_la

/home/elastic/elasticsearch/bin/elasticsearch-certutil cert --ca config/certs/ca --ca-pass elastic_la --name server1 --out config/certs/server1 --pass elastic_la

/home/elastic/elasticsearch/bin/elasticsearch-certutil cert --ca config/certs/ca --ca-pass elastic_la --name server2 --out config/cert/server2 --pass elastic_la

/home/elastic/elasticsearch/bin/elasticsearch-certutil cert --ca config/cert/ca --ca-pass elastic_la --name server3 --out config/cert/server3 --pass elastic_la

ll
```
### scp cers to others nodes
```
mv /home/elastic/elasticsearch/config/certs/* /tpm
chown elastic:elastic  /tmp/*
scp /home/elastic/elasticsearch/config/certs/server2 <ip>:/tmp/.
```

### Assign permissions to the certs and mv

```
chowm elastic:elastic /tmp/*
mv /tmp/cert /home/elasticsearch/config/cert/.
```

### Add key to elasticsearch to all nodes

```
./bin/elasticsearch-keystore add xpack.security.transport.ssl.keystore.secure_password

"Enter:" elastic_la

./bin/elasticsearch-keystore add xpack.security.transport.ssl.truststore.secure_password

"Enter:" elastic_la

./bin/elasticsearch-keystore add xpack.security.http.ssl.keystore.secure_password

"Enter:" elastic_la

./bin/elasticsearch-keystore add xpack.security.http.ssl.truststore.secure_password

"Enter:" elastic_la

./bin/elasticsearch-keystore list

```
### In order to delete from the keystore list:

bin/elasticsearch-keystore remove xpack.security.transport.ssl.http.secure_password

### Configure Elasticsearch sll for all nodes

vi elasticsearch/config/elasticsearch.yml

```
#------------------------ X-Pack -------------------
xpack.security.enabled: true
xpack.security.transport.ssl.enabled: true
xpack.security.transport.ssl.verification_mode: certificate
xpack.security.transport.ssl.keystore.path: certs/server<>
xpack.security.transport.ssl.truststore.path: certs/server<>
xpack.security.http.ssl.enabled: true
xpack.security.http.ssl.keystore.path: certs/server<>
xpack.security.http.ssl.truststore.path: certs/server<>


```

### Restart Elasticsearch on all nodes

```
pkill -F pid; ./bin/elasticsearch -d -p pid

cat logs/c1.log
```

### Change usename and password for all nodes in kibana

vi kibana/config/kibana.yml

```
elasticsearch.username: "kibana"
elasticsearch.password: "elastic_la
```

### Check access to Elasticsearch

```
curl -u elastic localhost:9200

Enter host password for user 'elastic':
{
  "name" : "server4",
  "cluster_name" : "c2",
  "cluster_uuid" : "3gdrxYOwQ6WMtIRpsCBFnA",
  "version" : {
    "number" : "7.2.1",
    "build_flavor" : "default",
    "build_type" : "tar",
    "build_hash" : "fe6cb20",
    "build_date" : "2019-07-24T17:58:29.979462Z",
    "build_snapshot" : false,
    "lucene_version" : "8.0.0",
    "minimum_wire_compatibility_version" : "6.8.0",
    "minimum_index_compatibility_version" : "6.0.0-beta1"
  },
  "tagline" : "You Know, for Search"
}

curl -u elastic https://localhost:9200 -k

```

### Change port in Kibana

vi kibana/config/kibana.yml

```
elasticsearch.hosts: ["https://192.168.0.20:9200"]
#elasticsearch.host: ["https://localhost:9200"]

elasticsearch.ssl.verificationMode: none
```

/home/elastic/kibana/bin/kibana --allow-root

login to kibana as elastic

### <span style="color: yellow">&#x1F535; Define Role-Based Access Control Using Elasticsearch Security </span>

> Go to Security > roles > Create new role

> Go to Dev Tools >

*  the role is user

GET _security/role/user

```
{
  "user" : {
    "cluster" : [
      "read_ilm"
    ],
    "indices" : [
      {
        "names" : [
          "sample*"
        ],
        "privileges" : [
          "read",
          "monitor"
        ],
        "allow_restricted_indices" : false
      }
    ],
    "applications" : [ ],
    "run_as" : [ ],
    "metadata" : { },
    "transient_metadata" : {
      "enabled" : true
    }
  }
}
```

```
POST _security/role/user
{
  "indices": [
   {
     "names": ["sample-*"],
     "privileges": ["read", "write", "delete"]
   }
  ]
}
```

```
{
  "user" : {
    "cluster" : [ ],
    "indices" : [
      {
        "names" : [
          "sample-*"
        ],
        "privileges" : [
          "read",
          "write",
          "delete"
        ],
        "allow_restricted_indices" : false
      }
    ],
    "applications" : [ ],
    "run_as" : [ ],
    "metadata" : { },
    "transient_metadata" : {
      "enabled" : true
    }
  }
}
```
