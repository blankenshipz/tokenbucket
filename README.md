# TokenBucket

A Simple GenServer implementation of the [TokenBucket Algorithm](https://en.wikipedia.org/wiki/Token_bucket)
used primarily for rate limiting

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `tokenbucket` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:tokenbucket, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/tokenbucket](https://hexdocs.pm/tokenbucket).

## Usage

A `TokenBucket` process can be started with any of the ways that you start a `GenServer`
perhaps most commonly as part of your application supervision tree:

```elixir
children = [
  { TokenBucket, name: SuperBucket, capacity: 20, cadence: 1000},
]

opts = [strategy: :one_for_one, name: TokenBucket.Supervisor]
Supervisor.start_link(children, opts)
```

Once the process is started the "bucket" will begin to fill at the rate set by `cadence`;
until the `capacity` is reached.

Tokens can be removed from the bucket with `take` or `await`

`TokenBucket.take` returns immediately 

```elixir
case TokenBucket.take(SuperBucket) do
  :ok ->
    IO.puts "We got a token!"
  :empty ->
    IO.puts "Better luck next time!"
end
```

While `TokenBucket.await` blocks for its turn to get a token

```elixir
TokenBucket.await(SuperBucket) // blocks
```

