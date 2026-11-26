---
title: anlytic service
---

!!! note "This service is still "

## flow overview

This service concentrates mostly on the _"requests (as confugured)"_ so the real image would look like this

```plantuml
start

partition "requests (as configured)" {
  fork
    :http request;
    :http response;
  fork again
    :dns request;
    :dns response;
  end fork
}

:log / save result;
stop
@enduml
```

