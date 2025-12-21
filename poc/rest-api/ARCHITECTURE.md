# Architecture

This project follows a lightweight Clean Architecture layout to keep HTTP, domain logic, and storage decoupled and easy to swap.

## Dependency Direction

Only depend inward toward the core domain:

```
cmd/server (composition)
   ├─ interfaces/http (handlers, router) ─┐
   │                                      │
   └─ infrastructure/* (repo impls)       │
           │                              │
           └────────→ usecase ─────────→ domain
```

- `domain` has no imports from other layers.
- `usecase` depends only on `domain` interfaces and entities.
- `interfaces/http` imports `usecase` (and Fiber) to translate HTTP ↔ domain.
- `infrastructure` implements `domain` interfaces; no HTTP imports.
- `cmd/server` wires concrete implementations; it is the only place where outward dependencies meet.

## Layer Responsibilities

- `domain/`: Core business rules. Defines entities (`Todo`), errors (`ErrTodoNotFound`), validation (`Validate`), and repository contracts (`TodoRepository`). Pure Go; no HTTP/DB/framework imports.
- `usecase/`: Application services (`TodoUsecase`). Coordinates operations across repositories, enforces domain validation, and holds workflow policies. Depends only on `domain` abstractions.
- `interfaces/http/`: Delivery layer for HTTP. Fiber router + handlers. Converts HTTP requests to DTOs, invokes usecases, maps domain errors to status codes, and renders JSON responses. Does not import infrastructure/DB code.
- `infrastructure/`: External adapters. Implementations of `domain` interfaces (e.g., `memory/TodoRepository`; add `postgres/` later). Can import DB drivers, caches, queues, etc., but must not depend on HTTP.
- `cmd/server/`: Composition root. Instantiates concrete adapters, wires them into usecases, then handlers, registers routes, and starts Fiber. The only package that knows about all other layers.

## Request Flow (example: update todo)

1. Fiber matches `PUT /todos/:id` → `TodoHandler.Update`.
2. Handler parses JSON to `UpdateTodoRequest`, then calls `TodoUsecase.Update`.
3. Usecase loads the entity via `TodoRepository.GetByID`, mutates fields, validates via `Todo.Validate`, and persists with `TodoRepository.Update`.
4. Usecase returns the updated `domain.Todo`; handler maps it to `TodoResponse` and writes JSON.

## Swapping Infrastructure

To move from in-memory to a database, add a new repo implementation under `infrastructure/` that satisfies `domain.TodoRepository`, then swap the constructor in `cmd/server/main.go`. Higher layers remain unchanged.
