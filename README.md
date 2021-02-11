![Bank CI](https://github.com/lucaslvs/bank/workflows/Bank%20CI/badge.svg) [![SourceLevel](https://app.sourcelevel.io/github/lucaslvs/-/bank.svg)](https://app.sourcelevel.io/github/lucaslvs/-/bank) [![Coverage Status](https://coveralls.io/repos/github/lucaslvs/bank/badge.svg?branch=master)](https://coveralls.io/github/lucaslvs/bank?branch=master)

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

  > This mix task will:
  >
  > - Install the dependencies.
  > - Create the database.
  > - Run the migrations on the database.
  > - Run the [priv/repo/seeds.exs](https://github.com/lucaslvs/bank/blob/master/priv/repo/seeds.exs) script file.

## Development

- To run the server:

    ```sh
    mix phx.server
    ```

  > You can access the server at [http://localhost:4000](http://localhost:4000).

- To run the elixir with the project REPL:

    ```sh
    iex -S mix
    ```

- To run the server with the elixir REPL:

    ```sh
    iex -S mix phx.server
    ```

  > You can access the server at [http://localhost:4000](http://localhost:4000) too.

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

  > This mix task will generate a `excoveralls.html` file in `cover` folder.

## Deployng

To deploy this project, you only need to merge in master branch and the [Github Actions](https://github.com/features/actions).
The main workflow, will schedule 3 jobs, `test`, `lint` and `deploy`.

- The `test` job run the tests and report the coverage in [Coveralls](https://coveralls.io/github/lucaslvs/bank).
- The `lint` job Run the formatter check and [Credo](https://github.com/rrrene/credo) linter.
- The `deploy` job only runs if `test` and `lint` jobs was successfull and push the new [Release](https://hexdocs.pm/mix/Mix.Tasks.Release.html) with [Gigalixir](https://www.gigalixir.com/).

> You can access the production server at [https://stone-bank.gigalixirapp.com](https://stone-bank.gigalixirapp.com)

## API Endpoints

🔐 **Authentication**

Requests to authenticated endpoints are authorized through a Bearer token that should be provided in the `Authorization` HTTP header. Check the [`/api/v1/tokens`](##post-apiv1token) endpoint for further details on how to generate Bearer tokens.


## POST /api/v1/tokens

Authenticates the user using `email` and `password` credentials and generates an JWT token to use in another endpoints.

### Parameters

| Name       | Required | Type   | Description     |
|------------|----------|--------|-----------------|
| `email`    | required | string | A user email    |
| `password` | required | string | A user password |

### Response

**Status**: `201 Created`

**Body**:
```json
{
  "token":  "A JWT token"
}
```

## GET /api/v1/accounts

🔐 **Authenticated**

Return the data of the authenticated user account such as its balance and number.

### Response

When account exists.

**Status**: `200 Success`

**Body**:

```json
{
  "account": {
    "balance": "R$ 890.00",
    "id": 1,
    "insertedAt": "2021-02-11 04:49:52",
    "number": "654321",
    "updatedAt": "2021-02-11 05:01:47",
    "userId": 1
  }
}
```

When there isn't a valid JWT token.

**Status**: `401 Unauthorized`

**Body**:
```json
{
  "errors": {
    "detail": "Unauthenticated"
  }
}
```

## POST /api/v1/accounts/transfer

🔐 **Authenticated**

Transfer the given amount from authenticated user account to target account.

### Parameters

| Name                  | Required | Type    | Description                      |
|-----------------------|----------|---------|----------------------------------|
| `targetAccountNumber` | required | string  | Target account to deposit amount |
| `amount`              | required | integer | The amount to be transferred     |

### Response

When all transfer validation are pass.

**Status**: `201 Created`

**Body**:
```json
{
  "source": {
    "account": {
      "balance": "R$ 790.00",
      "id": 1,
      "insertedAt": "2021-02-11 04:49:52",
      "number": "654321",
      "updatedAt": "2021-02-11 06:59:04",
      "userId": 1
    },
    "transaction": {
      "accountId": 1,
      "amount": "R$ -100.00",
      "id": 4,
      "insertedAt": "2021-02-11 06:59:04",
      "type": "transfer_withdrawal",
      "updatedAt": "2021-02-11 06:59:04"
    }
  },
  "target": {
    "account": {
      "balance": "R$ 1,100.00",
      "id": 2,
      "insertedAt": "2021-02-11 06:58:58",
      "number": "123456",
      "updatedAt": "2021-02-11 06:59:04",
      "userId": 2
    },
    "transaction": {
      "accountId": 2,
      "amount": "R$ 100.00",
      "id": 5,
      "insertedAt": "2021-02-11 06:59:04",
      "type": "transfer_deposit",
      "updatedAt": "2021-02-11 06:59:04"
    }
  }
}
```

When a transfer validation like authenticated user account has a insufficient balance, the transfer fails.

**Status**: `422 Unprocessable entity`

**Body**:
```json
{
  "errors": {
    "withdrawalAccount": {
      "balance": [
        "insufficient balance"
      ]
    }
  }
}
```

When a transfer validation like the received amount value that is negative or zero, the transfer fails.

**Status**: `422 Unprocessable entity`

**Body**:
```json
{
  "errors": {
    "withdrawalAccount": {
      "balance": [
        "must be greater than R$ 0.00"
      ]
    }
  }
}
```

## POST /api/v1/accounts/deposit

🔐 **Authenticated**

Deposit the given amount in authenticated user account.

### Parameters

| Name     | Required | Type    | Description              |
|----------|----------|---------|--------------------------|
| `amount` | required | integer | The amount to be deposit |

### Response

When all deposit validation are pass.

**Status**: `201 Created`

**Body**:
```json
{
  "account": {
    "balance": "R$ 890.00",
    "id": 1,
    "insertedAt": "2021-02-11 04:49:52",
    "number": "654321",
    "updatedAt": "2021-02-11 07:11:43",
    "userId": 1
  },
  "transaction": {
    "accountId": 1,
    "amount": "R$ 100.00",
    "id": 9,
    "insertedAt": "2021-02-11 07:11:43",
    "type": "deposit",
    "updatedAt": "2021-02-11 07:11:43"
  }
}
```
When a transfer validation like the received amount value that is negative or zero, the transfer fails.

**Status**: `422 Unprocessable entity`

**Body**:
```json
{
  "errors": {
    "depositAccount": {
      "balance": [
        "must be greater than R$ 0.00"
      ]
    }
  }
}
```

## POST /api/v1/accounts/withdraw

🔐 **Authenticated**

Withdraw the given amount from authenticated user account.

### Parameters

| Name     | Required | Type    | Description                  |
|----------|----------|---------|------------------------------|
| `amount` | required | integer | The amount to be transferred |

### Response

When all withdraw validation are pass.

**Status**: `201 Created`

**Body**:
```json
{
  "account": {
    "balance": "R$ 880.00",
    "id": 1,
    "insertedAt": "2021-02-11 04:49:52",
    "number": "654321",
    "updatedAt": "2021-02-11 07:19:49",
    "userId": 1
  },
  "transaction": {
    "accountId": 1,
    "amount": "R$ -10.00",
    "id": 10,
    "insertedAt": "2021-02-11 07:19:49",
    "type": "withdraw",
    "updatedAt": "2021-02-11 07:19:49"
  }
}
```

When a withdraw validation like authenticated user account has a insufficient balance, the withdraw fails.

**Status**: `422 Unprocessable entity`

**Body**:
```json
{
  "errors": {
    "withdrawalAccount": {
      "balance": [
        "insufficient balance"
      ]
    }
  }
}
```

When a transfer validation like the received amount value that is negative or zero, the transfer fails.

**Status**: `422 Unprocessable entity`

**Body**:
```json
{
  "errors": {
    "withdrawalAccount": {
      "balance": [
        "must be greater than R$ 0.00"
      ]
    }
  }
}
```

## POST /api/v1/accounts/transactions

🔐 **Authenticated**

Returns a transactions page by the given query parameters with the pageTotalAmount and `totalAmount` of the query.

### Parameters

| Name            | Required | Type    | Description                                                                                                                         |
|-----------------|----------|---------|-------------------------------------------------------------------------------------------------------------------------------------|
| `insertedFrom`  | optional | string  | the date that limits the query with entries that has insertedAt field greater than or equal to the received value. Ex: "2021-02-10" |
| `insertedUntil` | optional | string  | the date that limits the query with entries that has insertedAt field less than or equal to the received value. Ex: "2021-02-11"    |
| `pageSize`      | optional | integer | The page number                                                                                                                     |
| `page`          | optional | integer | The number of transactions page                                                                                                     |

### Response

**Status**: `201 Created`

**Body**:
```json
{
  "pageNumber": 1,
  "pageSize": 3,
  "pageTotalAmount": "R$ 110.02",
  "totalAmount": "R$ 720.02",
  "totalPages": 4,
  "totalTransactions": 10,
  "transactions": [
    {
      "accountId": 1,
      "amount": "R$ 110.00",
      "id": 1,
      "insertedAt": "2021-02-10 22:51:30",
      "type": "deposit",
      "updatedAt": "2021-02-10 22:51:30"
    },
    {
      "accountId": 1,
      "amount": "R$ -0.01",
      "id": 2,
      "insertedAt": "2021-02-10 05:01:09",
      "type": "withdraw",
      "updatedAt": "2021-02-11 23:01:09"
    },
    {
      "accountId": 1,
      "amount": "R$ 0.01",
      "id": 3,
      "insertedAt": "2021-02-10 05:01:09",
      "type": "deposit",
      "updatedAt": "2021-02-11 05:01:47"
    }
  ]
}
```

If `insertedFrom` or `insertedUntil` has a invalid format.

**Status**: `422 Unprocessable entity`

**Body**:
```json
{
  "error": {
    "message": "invalid date format"
  }
}
```
