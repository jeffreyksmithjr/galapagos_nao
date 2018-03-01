FROM jeffreyksmithjr/elixir-mxnet

COPY . .

RUN mix local.hex --force

RUN mix deps.get
RUN mix format --check-formatted
RUN mix compile

CMD iex -S mix