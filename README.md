# Nookal

Elixir client for [Nookal API](https://nookal.com).

## Installation

Add Nookal as an dependency in your `mix.exs` file.

```elixir
def deps() do
  [{:nookal, ">= 0.0.0"}]
end
```

Aftet that, run `mix deps.get`. Please add `:nookal` to your list of `:applications` if you are not using `:extra_applications`.

## Usage

Nookal requires some configurations to be set before using. For example, in your `config/config.exs`:

```elixir
config :nookal, api_key: "very-secretive"
```

Then you are good to go:

```elixir
iex> Nookal.verify()
:ok

iex> Nookal.get_practitioners()
{:ok,
 %Nookal.Page{
   current: 1,
   items: [
     %Nookal.Practitioner{
       email: "test@example.com",
       first_name: "Erik",
       id: "9",
       last_name: "Johanson",
       location_ids: [1],
       speciality: "Doctor",
       title: "Dr"
     },
   ],
   next: nil
 }}
```

## Contributing

To run tests:

```
mix test --no-start
```

## License

MIT, Copyright 2019 Agile Lab
