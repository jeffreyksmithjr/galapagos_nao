<img src="resources/turtle_logo.png" width="300">

[![Build Status](https://travis-ci.org/jeffreyksmithjr/galapagos_nao.svg?branch=master)](https://travis-ci.org/jeffreyksmithjr/galapagos_nao)
[![codebeat badge](https://codebeat.co/badges/f2812f2e-4c0c-4b6c-812f-ff693e5e5fd5)](https://codebeat.co/projects/github-com-jeffreyksmithjr-galapagos_nao-master)
# Galápagos Nǎo
_A playground for interactive neuroevolution_

## Installation

Since this library uses both Elixir and Python, the easiest way of getting started is to pull the latest Docker image: [jeffreyksmithjr/galapagos_nao](https://hub.docker.com/r/jeffreyksmithjr/galapagos_nao/)

## Getting Started

To see an example execution, you can use the provided example data.

```
iex(1)> example_task = GN.Example.start()
Generations remaining: 2
Epoch 0. Loss: 1.82401811845, Train_acc 0.850116666667, Test_acc 0.8553
Epoch 0. Loss: 1.78003315557, Train_acc 0.844516666667, Test_acc 0.853
Epoch 0. Loss: 2.21335139497, Train_acc 0.871866666667, Test_acc 0.8784
Epoch 0. Loss: 3.6475392971, Train_acc 0.7559, Test_acc 0.76
...
```

This will spawn a series of Tasks which will asynchronously execute.

You can await the completion of the Tasks at any time, but this will block your session, if the Tasks are not complete.
```
iex(2)> GN.Example.final(example_task)
%Task{
  owner: #PID<0.189.0>,
  pid: #PID<0.201.0>,
  ref: #Reference<0.1759494759.3124232195.141142>
}
```


At any point in the learning process, before, during, or after, you can inspect the best learn models.

```
iex(3)> GN.Selection.get_all()
%{
  1 => %GN.Network{
    id: "0c2020ad-8944-4f2c-80bd-1d92c9d26535",
    layers: [
      dense: [64, :softrelu],
      batch_norm: [],
      activation: [:relu],
      dropout: [0.5],
      dense: [63, :relu]
    ],
    test_acc: 0.8553
  },
  2 => %GN.Network{
    id: "0c2020ad-8944-4f2c-80bd-1d92c9d26535",
    layers: [
      dense: [64, :relu],
      batch_norm: [],
      batch_norm: [],
      dropout: [0.5],
      dense: [64, :relu],
      leaky_relu: [0.2],
      batch_norm: []
    ],
    test_acc: 0.8784
  }
}
```
