![Bank CI](https://github.com/lucaslvs/bank/workflows/Bank%20CI/badge.svg) [![SourceLevel](https://app.sourcelevel.io/github/lucaslvs/-/bank.svg)](https://app.sourcelevel.io/github/lucaslvs/-/bank) [![Coverage Status](https://coveralls.io/repos/github/lucaslvs/bank/badge.svg)](https://coveralls.io/github/lucaslvs/bank)

# Bank

A basic banking API build with [Elixir](http://elixir-lang.org).

## Requirements

- Elixir 1.11.3
- Erlang 23.2
- Postgres 12.5

## Setup

- Clone and access this repo:

  ```sh
  git clone git@github.com:lucaslvs/bank.git && cd bank
  ```

- Install the dependencies and the database

  ```sh
  mix setup
  ```

  > This following mix task will:
  > 1º - Install the dependencies.
  > 2º - Create the database.
  > 3º - Run the migrations on the database.
  > 4 - Run the `priv/repo/seeds.exs` script file.

## Development

- To run the server:

  ```sh
  mix phx.server
  ```

  > You can access the server routes at `http://localhost:4000`.

- To run the elixir with the project REPL:

  ```sh
  iex -S mix
  ```

- To run the server with the elixir REPL:

  ```sh
  iex -S mix phx.server
  ```

  > You can access the server routes at `http://localhost:4000` too.

- To list all available routes:

  ```sh
  mix phx.routes
  ```

## Testing

- To run the tests:

  ```sh
  mix test
  ```

- To run the tests and see the coverage:

  ```sh
  mix coveralls
  ```

- To run the tests and see the coverage in a HTML file:

  ```sh
  mix coveralls.html
  ```

  > This comand will generate a `excoveralls.html` file in `cover` folder.

## Deployng

> TODO
