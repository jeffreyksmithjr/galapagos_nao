FROM microsoft/cntk:2.5.1-cpu-python2.7

RUN wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb \
    && sudo dpkg -i erlang-solutions_1.0_all.deb
RUN sudo apt-get update
RUN sudo apt-get install -y esl-erlang
RUN sudo apt-get install -y elixir

CMD ["bash"]