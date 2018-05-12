FROM jeffreyksmithjr/elixir-cntk

COPY . .

RUN mix local.hex --force
RUN mix local.rebar --force

RUN mix deps.get
RUN mix format --check-formatted
RUN mix compile
RUN bash ./test.sh

CMD bash