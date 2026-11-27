---
title: config
draft: true
---

## Example config

```json
{
  "activities": [
    {
      "name": "check dns",
      "type": "dns",
      "target": "example.com",
      "timeoutMs": 5000,
      "check": {
        "recordType": "A",
        "expectedValue": "2.2.2.2",
        "nameserver": "1.1.1.1",
        "followCname": true
      }
    },
    {
      "name": "check Site",
      "type": "http",
      "target": "https://example.com",
      "timeoutMs": 5000,
      "check": {
        "method": "GET",
        "expectedStatusCodes": [200],
        "verifyTls": true,
        "responseValidation": {
          "contentType": "application/json",
          "jsonPath": "$.status",
          "expectedValue": "ok",
          "maxResponseTimeMs": 2000
        }
      }
    }
  ],
  "ruleSet": {
    "maxDurationS": {
      "dns": 40,
      "http": 5
    }
  }
}
```

## fields

### activities

| field     | type     | allowed content              |
| --------- | -------- | ---------------------------- |
| name      | string   |                              |
| type      | string   | dns, http                    |
| target    | string   |                              |
| timeoutMs | integer  | < 100 - 60000                |
| labels    | object   |                              |
| check     | object<> | [DNS](#dns) or [HTTP](#http) |

#### check

##### dns

| field          | type    | allowed content                           |
| -------------- | ------- | ----------------------------------------- |
| recordType     | string  | "A", "AAAA", "CNAME", "TXT", "SOA", "SRV" |
| expectedValue  | string  | min: 1, max: 4096                         |
| followCname    | boolean | true (default), false                     |
| validateDnssec | boolean | true, false (default)                     |

##### http

| field               | type                                      | allowed content                                            |
| ------------------- | ----------------------------------------- | ---------------------------------------------------------- |
| method              | string                                    | "GET", "HEAD", "POST", "PUT", "PATCH", "DELETE", "OPTIONS" |
| expectedStatusCodes | array of integer                          | min: 100, max: 599                                         |
| followRedirects     | boolean                                   | true (default), false                                      |
| maxRedirects        | integer                                   | min: 0, max: 20, default: 5                                |
| verifyTls           | boolean                                   | true (default), false                                      |
| headers             | object                                    |                                                            |
| queryParams         | object                                    |                                                            |
| body                | object                                    |                                                            |
| responseValidation  | [responseValidation](#responsevalidation) |                                                            |

###### responseValidation

| field             | type               | allowed content   |
| ----------------- | ------------------ | ----------------- |
| contentType       | string             | min: 1, min: 255  |
| jsonPath          | string             | > 255             |
| expectedValue     |                    |                   |
| maxResponseTimeMs | min: 1, max: 60000 |                   |
| requiredHeaders   | array              |                   |
| bodyContains      | string             | min: 1, max: 4096 |

#### ruleset

| field        | type   | allowed content               |
| ------------ | ------ | ----------------------------- |
| maxDurationS | object | [maxDurationS](#maxdurations) |

##### maxDurationS

| field | type    | allowed content   | required |
| ----- | ------- | ----------------- | -------- |
| dns   | integer | min: 1, max: 3600 | yes      |
| http  | integer | min: 1, max: 3600 | yes      |
