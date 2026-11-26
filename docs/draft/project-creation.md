---
title: project creation
---

# Project creation

!!! warning "Draft"
    This page describes the **agreed flow**, not the current code. Parts of it are not implemented yet; see [Implementation status](#implementation-status).

Creating a project in LEX means registering a new **config** (one config per service/project). A config is checked, stored in the config repository, scheduled, and put on the queue. A project exists once all of these steps succeeded.

## Flow

```uml
@startuml "Project Creation"
participant "auth" as A
participant "token management" as tm
actor "user" as U
participant "config validation" as cv
participant "config management" as cm
participant "queue management" as qm
participant "scheduler" as s

alt user is not authenticated
    U -> A : login and authentication
    A -> U : returns session
else "user is machine user"
    U -> tm : validate token
    tm -> U : returns session
end
U -> cv: creates new config
alt config is invalid
    cv -> U: error message
end
cv -> cm: creates config in repo

cm -> s: schedule new config
s -> cm: returns success
cm -> qm: add new config to queue
qm -> cm: returns success
@enduml
```

## Steps

### 1. Authentication

Every request needs a session. There are two ways to get one:

| Caller                         | How                                                                | Handled by       |
| ------------------------------ | ------------------------------------------------------------------ | ---------------- |
| Human user (UI)                | Logs in and receives a session                                     | auth             |
| Machine user (API, automation) | Sends an API token, which is validated and exchanged for a session | token management |

If the caller has no valid session, the flow stops here.

### 2. Submit and validate the config

The user (or UI) submits the new config to **config validation** with the service name and the config body.

- The config is checked against the versioned JSON schemas for that service. The newest schema is tried first, then older ones; the first match wins and its version is reported.
- If the config is invalid, or the service is unknown, the user gets an error message listing the problems per schema version. **Nothing is stored** and the flow ends.

See the [validate endpoint](https://github.com/project-lex/config-validator) for request and response examples (`200` valid, `422` invalid, `400` malformed request).

### 3. Store the config

A valid config is passed to **config management**, which creates it in the config repository (GitHub). The service key is the file path without its extension, for example `payments/prod.json` becomes `payments/prod`. Config management keeps a copy in MongoDB so it can be read back by service key.

### 4. Schedule

Config management asks the **scheduler** to schedule the new config. The scheduler stores a schedule (`name`, `duration`), keeps a timer for it, and answers with success. When the timer expires it fires a webhook and marks the schedule as `fired`.

### 5. Queue

After the scheduler confirms, config management adds the config to the **queue** (`POST /queue`). The item gets the next free position and is processed in position order. Once the queue confirms, project creation is complete.

## Failure handling

| Step           | Failure                          | Result for the user | State left behind                              |
| -------------- | -------------------------------- | ------------------- | ---------------------------------------------- |
| Authentication | No or invalid session/token      | Rejected            | None                                           |
| Validation     | Config invalid / unknown service | Error message       | None                                           |
| Store          | Repo or database not reachable   | Error               | None                                           |
| Schedule       | Scheduler fails                  | Error               | Config exists in repo (_open question_)        |
| Queue          | Queue fails                      | Error               | Config in repo and scheduled (_open question_) |

!!! question "Open questions" 
    - **Rollback:** if scheduling or queueing fails after the config was stored, should creation be rolled back (delete config and schedule), or retried? The diagram does not say.
    - **Ordering:** the diagram schedules first and queues second. Should the queue step wait for the scheduler, or can both run in parallel? 
    - **Updates:** the same flow could handle changes to an existing config. Is that a separate flow?

## Implementation status

| Part                   | Status                                                                                               |
| ---------------------- | ---------------------------------------------------------------------------------------------------- |
| config validation      | Implemented (`POST /validate`).                                                                      |
| scheduler              | Implemented (`POST /schedule`, `GET /schedule`, `DELETE /schedule`).                                 |
| queue management       | Implemented (`POST /queue`, `GET /queue`, `POST /queue/next-item`).                                  |
| config management      | Reads and deletes configs only. **No create endpoint yet**, and it does not call scheduler or queue. |
| auth, token management | Token management is planned, not implemented.                                                        |
| orchestration          | Nothing yet connects validation, config management, scheduler and queue into this single flow.       |
