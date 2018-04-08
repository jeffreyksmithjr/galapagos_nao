<img src="resources/turtle_logo.png" width="300">

[![Build Status](https://travis-ci.org/jeffreyksmithjr/galapagos_nao.svg?branch=master)](https://travis-ci.org/jeffreyksmithjr/galapagos_nao)
[![codebeat badge](https://codebeat.co/badges/f2812f2e-4c0c-4b6c-812f-ff693e5e5fd5)](https://codebeat.co/projects/github-com-jeffreyksmithjr-galapagos_nao-master)
# Galápagos Nǎo
_/ɡəˈlapəɡəs naʊ/_

_1. A playground for continual, interactive neuroevolution_

_2. 1979 film known for the quote, "I love the smell of neurons in the morning."_

## Overview
Galápagos Nǎo is intended to allow for the exploration of these ideas about machine learning:
* [Neuroevolution](https://en.wikipedia.org/wiki/Neuroevolution)-the learning of deep learning architectures
* [Interactive evolution](https://en.wikipedia.org/wiki/Interactive_evolutionary_computation)-the use of human intelligence to guide evolution computation
* [Continual learning](http://continuousai.com/background/)-defining machine learning tasks to run idefinitely, while retaining learned knowledge
* [Illumination algorithms](https://arxiv.org/abs/1504.04909)-algorithms that attempt to illuminate the properties of the feature space, rather than optimize for singular solutions

From a programming perspective, it allows developers to explore:
* Integration of foreign language components
* Metaprogramming
* Functional programming techniques for machine learning

## Design

Galápagos Nǎo implements an analogous algorithm to [MAP-Elites](https://arxiv.org/abs/1504.04909), producing different possible solutions to a given learning task, along a range of dimensions.
The initial dimension of interest implemented is model complexity, providing a range of neural architectures, containing different levels of complexity.
The parameters around the desired number of complexity levels to be used when bucketing elites is controllable via the `:complexity_levels` parameter.
Elites are stored in the `Selection` process after each generation, and can be retrieved and inspected by the user, without interrupting training.
If a user wants to store a given elite it can be placed in the `Library` process for further reuse and reintroduction into the population for further evolution.

Learning can be done in a batch mode, with a user-supplied number of generations using the `GN.Orchestration.evolve/2` function or in a continual mode using the `GN.Orchestration.evolve_continual/1` function.

## Installation

Since this library uses both Elixir and Python, the easiest way of getting started is to pull the latest Docker image: [jeffreyksmithjr/galapagos_nao](https://hub.docker.com/r/jeffreyksmithjr/galapagos_nao/)

## Getting Started

To see an example execution, you can use the provided example data.

```
iex(1)> example_task = GN.Example.short_example()
Generations remaining: 2
Epoch 0. Loss: 1.82401811845, Train_acc 0.850116666667, Test_acc 0.8553
Epoch 0. Loss: 1.78003315557, Train_acc 0.844516666667, Test_acc 0.853
Epoch 0. Loss: 2.21335139497, Train_acc 0.871866666667, Test_acc 0.8784
Epoch 0. Loss: 3.6475392971, Train_acc 0.7559, Test_acc 0.76
...
```

This will spawn a series of Tasks which will asynchronously execute.
At the end of each generation, the best learned models will be stored in the `Selection` process.

These best models can be inspected at the end of the learning process or during it.

```
iex(2)> GN.Selection.get_all()
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
    id: "58229333-a05d-4371-8f23-e8e55c37a2ec",
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

## Continual Learning
Since the processes of learning and inspecting the results can occur concurrently, learning can continue indefinitely.
```
iex(3)> GN.Example.infinite_example()
%Task{
  owner: #PID<0.171.0>,
  pid: #PID<0.213.0>,
  ref: #Reference<0.1968944036.911736833.180535>
}
Generations remaining: infinity
```

The best learned models can be inspected at any time and then used without interrupting the continuous learning process.

```
iex(4)> GN.Selection.get_all()
%{
  1 => %GN.Network{
    id: "1b2d4f81-7a64-4529-92ed-74a7257fc00e",
    layers: [batch_norm: [], flatten: [], dense: [63, :none], flatten: []],
    test_acc: 0.8623
  }, 
  2 => %GN.Network{
    id: "d2d3480b-c9b6-4751-9762-78d7a20ee34a",
    layers: [
      dense: [64, :relu],
      batch_norm: [],
      leaky_relu: [0.4531755308368629],
      dense: [62, :none],
      flatten: [],
      leaky_relu: [0.06572503974712329],
      dense: [64, :none]
    ],
    test_acc: 0.8717
  }
}
```

These models can be placed in the `Library`. This process simply snapshots the models for future use. The originals remain in the population to give rise to future mutated offspring models.

```
iex(5)> network = GN.Selection.get_all() |> Map.get(2)   
%GN.Network{
  id: "a5b54fdd-8338-4001-a2e6-9285b150178d",
  layers: [
    dense: [64, :relu],
    dense: [64, :relu],
    batch_norm: [],
    dense: [64, :relu],
    flatten: [],
    dense: [64, :relu]
  ],
  test_acc: 0.8811
}
iex(6)> GN.Library.put(network)
:ok
```

Models can be retrieved by their IDs.
```
iex(7)> GN.Library.get("a5b54fdd-8338-4001-a2e6-9285b150178d")
%GN.Network{
  id: "a5b54fdd-8338-4001-a2e6-9285b150178d",
  layers: [
    dense: [64, :relu],
    dense: [64, :relu],
    batch_norm: [],
    dense: [64, :relu],
    flatten: [],
    dense: [64, :relu]
  ],
  test_acc: 0.8811
}
```

## Interactive Neuroevolution

Continuous learning processes work well in combination with the interactivity functionality Via the functions exposed by the `Parameters` module, the user can guide the evolution of new architectures, according to human intuition.

```
iex(8)> GN.Parameters.put(GN.Selection, %{complexity_levels: 4})
:ok
```

The learning process will then pick up these new parameters and alter the behavior of the evolutionary system on the next generation.

```
iex(8)> GN.Selection.get_all()                                  
%{
  1 => %GN.Network{
    id: "dc7844db-ce67-4905-9749-0650bcb97a50",
    layers: [
      batch_norm: [],
      activation: [:tanh],
      dense: [63, :none],
      flatten: []
    ],
    test_acc: 0.8653
  },
  2 => %GN.Network{
    id: "db3973f9-5b8a-4694-ad56-4a39027c6f1d",
    layers: [
      dense: [64, :relu],
      batch_norm: [],
      leaky_relu: [0.4531755308368629],
      dense: [62, :none],
      flatten: [],
      leaky_relu: [0.06572503974712329], 
      dense: [64, :none]
    ],
    test_acc: 0.8717
  },
  3 => %GN.Network{
    id: "fdb3dc01-40eb-45eb-b3f3-6ce8b38745a7", 
    layers: [
      batch_norm: [],
      activation: [:tanh],
      dense: [65, :softrelu],
      flatten: []
    ],
    test_acc: 0.8612
  },
  4 => %GN.Network{
    id: "670c227a-9da0-472d-bf00-1324ed20c63b",
    layers: [
      dense: [64, :none],
      batch_norm: [],
      dropout: [0.5],
      leaky_relu: [0.2],
      leaky_relu: [0.06572503974712329],
      flatten: [],
      dense: [65, :none]
    ],
    test_acc: 0.8464
  }
}
```
You can also interact with the models in the population by storing models in the library and then later reintroducing them into the population.
```
iex(9)> GN.Selection.get_all() |> Map.get(2) |> GN.Library.put()              
iex(10)> GN.Library.get("02b2a947-f888-4abf-b2a5-5df25668b0ee") |> GN.Selection.put_unevaluated()
```
The `GN.Selection.put_unevaluated/1` function is used to place (clones of) models back into the population without removing any existing elite learned models. On the next generation, all models will be reevaluated for their fitness, and only the elites will be preserved for future generations. Models stored in the library will remain until removed, independent of the current state of any ongoing evolution.
