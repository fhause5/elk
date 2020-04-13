### <span style="color: red">&#x1F535; Elasticsearch in production </span>

# <span style="color: red">&#x1F535; To restart cluster: </span>


### Check green state

> curl -u elastic https://localhost:9200/_cat/health?v -k


### Enable the new_primaries

```
curl -X PUT -u elastic https://localhost:9200/_cluster/settings?pretty -k -H 'Content-Type: application/json' -d'
{
  "persistent": {
    "cluster.routing.allocation.enable": "new_primaries"
  }
}'

systemctl restart elasticsearch

```

### To default

```
curl -X PUT -u elastic https://localhost:9200/_cluster/settings?pretty -k -H 'Content-Type: application/json' -d'
{
  "persistent": {
    "cluster.routing.allocation.enable": null
  }
}'
```

![](screens/update.png)

### With downtime

![](screens/update2.png)

### Versions:

![](screens/update3.png)
# <span style="color: red">&#x1F535; Update cluster </span>


```
curl localhost:9200/_cat/health?v
```
We should see something like this:

epoch      timestamp cluster       status node.total node.data shards pri relo init unassign pending_tasks max_task_wait_time active_shards_percent
1529337171 11:52:51  elasticsearch green           1         1      0   0    0    0        0             0                  -                100.0%
Now we can reduce shard allocation to new_primaries with this:

```
curl -X PUT "localhost:9200/_cluster/settings?pretty" -H 'Content-Type: application/json' -d '
{
  "persistent": {
    "cluster.routing.allocation.enable": "new_primaries"
  }
}'
Our output should look like this:

{
  "acknowledged" : true,
  "persistent" : {
    "cluster" : {
      "routing" : {
        "allocation" : {
          "enable" : "new_primaries"
        }
      }
    }
  },
  "transient" : { }
}
```

Now let's run this:

```
curl localhost:9200/_cluster/settings?pretty
```

We should get some output that looks like this:
```
{
   "persistent" : {
     "cluster" : {
       "routing" : {
         "allocation" : {
           "enable" : "new_primaries"
         }
       }
     }
   },
   "transient" : { }
}
```
Stop Elasticsearch
Stop the elasticsearch service with:
```
systemctl stop elasticsearch
Check that the service is shut down with:

systemctl status elasticsearch
Upgrade Elasticsearch to 6.3.0 via YUM
Upgrade Elasticsearch to version 6.3 with:

yum update elasticsearch-6.3.0 -y
Perform a daemon-reload to pick up the changes to elasticsearch.service with:

systemctl daemon-reload

```

Start Elasticsearch
Start Elasticsearch with:

```
systemctl start elasticsearch
Check that the service has started with:

systemctl status elasticsearch
Increase Shard Allocation to all
Increase shard allocation to all with:
```

```
curl -X PUT "localhost:9200/_cluster/settings?pretty" -H 'Content-Type: application/json' -d '
{
  "persistent": {
    "cluster.routing.allocation.enable": "all"
  }
}'
```
We should see output like this:

```
{
  "acknowledged" : true,
  "persistent" : {
    "cluster" : {
      "routing" : {
        "allocation" : {
          "enable" : "all"
        }
      }
    }
  },
  "transient" : { }
}
```

### Monitoring
![](screens/monitoring.png)

```
/etc/elasticsearch/elasticsearch.yml

xpack.monitoring.collection.enabled: true
xpack.monitoring.exporters:
  1:
    type: http
    host: "http:/site_local_address_of_monitor_cluster:9200"


systemctl restart elasticsearch

```

### Curator
![](screens/curator.png)

vi /etc/yum.repos.d/curator.repo

```
[curator-5]
name=CentOS/RHEL 7 repository for Elasticsearch Curator 5.x packages
baseurl=https://packages.elastic.co/curator/5/centos/7
gpgcheck=1
gpgkey=https://packages.elastic.co/GPG-KEY-elasticsearch
enabled=1
```

```
yum install elasticsearch-curator -y
mkdir /etc/curator
cd /etc/curator
```

vi config.yml
```
---

client:
  hosts:
    - localhost
  port: 9200
  master_only: true
# if we have one node  
logging:
  loglevel: INFO
```

/etc/curator/actions.yml

```
---

actions:
  1:
    action: delete_indices
    description: delete non-system indexes older than 90 days
    options:
      ignore_empty_list: true
    filters:
    - filtertype: pattern
      kind: prefix
      value: '\.'
      exclude: true
    - filtertype: age
      source: field_stats
      field: '@timestamp'
      direction: older
      unit: days
      unit_count: 90
      stats_result: max_value
```
### Check congigs

```
curator --config /etc/curator/config.yml /etc/curator/actions.yml
```
