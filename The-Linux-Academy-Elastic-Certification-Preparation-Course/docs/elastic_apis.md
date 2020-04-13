### <span style="color: blue">&#x1F535; Elasticsearch CAT APIs </span>


```
curl -u elastic https://192.168.0.20:9200/_cat -k

----
/_cat/allocation
/_cat/shards
/_cat/shards/{index}
/_cat/master

```

### Searching and Filtering


GET bank/_search?q=Filodyne


GET bank/_search
{
  "query": {
    "match": {
      "age": "25"
    }
  }
}

### Aggregating

```
GET bank
GET bank/_search
{
  "aggs": {
    "accounts_per_state": {
      "terms": {
        "field": "state.keyword",
         "size": 10
      }
    }
  }
}

GET bank/_search?size=0
{
  "aggs": {
    "average_balance": {
      "max": {
        "field": "balance"
      }
    }
  }
}


GET bank/_search?size=0
{
  "aggs": {
    "age_bracket": {
      "range": {
        "field": "age",
        "ranges": [
          {
            "from": 18,
            "to": 25
          },
          {
            "from": 25,
            "to": 35
          },
          {
            "from": 35,
            "to": 50
          }
        ]
      },
        "aggs": {
          "average_balance": {
            "avg": {
              "field": "balance"
            }
          }
        }

    }
  }
}
```
