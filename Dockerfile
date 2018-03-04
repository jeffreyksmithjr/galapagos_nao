FROM jeffreyksmithjr/elixir-mxnet

COPY . .

RUN mix local.hex --force
RUN mix local.rebar --force

RUN mix deps.get
RUN mix format --check-formatted
RUN mix compile
RUN mix test

CMD iex -S mix