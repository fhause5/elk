### <span style="color: pink">&#x1F535; Elastic Certified Engineer </span>

### aliases

```
PUT bank/_alias/testing
```

### templates

```
PUT _template/date-logs
{
  "aliases": {
    "main-date": {}
  },
  "mappings": {

    "properties": {
      "geo": {
        "properties": {
          "coordinates": {
            "type": "geo_point"
          }
        }
      }
    }

  },
  "settings": {
    "number_of_shards": 1,
    "number_of_replicas": 2
  },
  "index_patterns": "date-logs*"

}

PUT date-logs-2020-04-10

GET date-logs-2020-04-10
```

### Dynamic Template

```
POST example-1/_doc
{
  "firstname": "snap",
  "lastname": "fhause5",
  "age": 35,
  "text": "This is a simple example"
}

PUT example-1
{

  "mappings": {
    "dynamic_templates": [
      {
        "strings_to_keyword": {
          "match_mapping_type": "string",
          "unmatch": "*_text",
          "mapping": {
            "type": "keyword"
          }
        }
      },
      {

        "to_integer": {
          "match_maping_type": "long",
          "mapping": {
            "type": "integer"
          }
        }
      },
      {
        "string_to_text": {
          "match_mapping_type": "string",
          "match": "*_text",
          "mapping": {
            "type": "text"
          }
        }
      }
    ]  
  }
}

GET example-1/_search/
```


### Perform Index, Create, Read, Update, and Delete Operations on the Documents of an Index

### create

```
GET _cat/nodes?v

GET _cat/indices?v

GET bank
PUT bank
{
  "settings": {
    "number_of_shards": 1,
    "number_of_replicas": 1
  }

}
```


```
curl -O https://raw.githubusercontent.com/linuxacademy/content-elastic-certification/master/sample_data/logs.json

curl -O https://raw.githubusercontent.com/linuxacademy/content-elastic-certification/master/sample_data/accounts.json

curl -O https://raw.githubusercontent.com/linuxacademy/content-elastic-certification/master/sample_data/shakespeare.json

```

```
curl -u elastic -k -H 'Content-Type: application/x-ndjson' -X POST 'https://192.168.0.20:9200/bank/_bulk?pretty' --data-binary @accounts.json > accounts_bulk.json
```


```
GET _cat/nodes?v

GET _cat/indices?v

GET bank/_search
GET bank/_source/1

GET bank
PUT bank
{
  "settings": {
    "number_of_shards": 1,
    "number_of_replicas": 1
  }

```
