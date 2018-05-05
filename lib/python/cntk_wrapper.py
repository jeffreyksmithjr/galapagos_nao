# Copyright (c) Microsoft. All rights reserved.

# Licensed under the MIT license. See LICENSE.md file in the project root
# for full license information.
# ==============================================================================

import argparse
import numpy as np
import sys
import os
import cntk as C
from cntk.train import Trainer, minibatch_size_schedule 
from cntk.io import MinibatchSource, CTFDeserializer, StreamDef, StreamDefs, INFINITELY_REPEAT
from cntk.device import cpu, try_set_default_device
from cntk.learners import adadelta, learning_parameter_schedule_per_sample
from cntk.ops import relu, element_times, constant
from cntk.layers import Dense, Sequential, For
from cntk.losses import cross_entropy_with_softmax
from cntk.metrics import classification_error
from cntk.train.training_session import *
from cntk.logging import ProgressPrinter, TensorBoardProgressWriter

abs_path = os.path.dirname(os.path.abspath(__file__))

def check_path(path):
    if not os.path.exists(path):
        readme_file = os.path.normpath(os.path.join(
            os.path.dirname(path), "..", "README.md"))
        raise RuntimeError(
            "File '%s' does not exist. Please follow the instructions at %s to download and prepare it." % (path, readme_file))

def create_reader(path, is_training, input_dim, label_dim):
    return MinibatchSource(CTFDeserializer(path, StreamDefs(
        features  = StreamDef(field='features', shape=input_dim, is_sparse=False),
        labels    = StreamDef(field='labels',   shape=label_dim, is_sparse=False)
    )), randomize=is_training, max_sweeps = INFINITELY_REPEAT if is_training else 1)


# Creates and trains a feedforward classification model for MNIST images

def simple_mnist():
    input_dim = 784
    num_output_classes = 10
    num_hidden_layers = 1
    hidden_layers_dim = 200

    # Input variables denoting the features and label data
    feature = C.input_variable(input_dim, np.float32)
    label = C.input_variable(num_output_classes, np.float32)

    # Instantiate the feedforward classification model
    scaled_input = element_times(constant(0.00390625), feature)

    z = Sequential([For(range(num_hidden_layers), lambda i: Dense(hidden_layers_dim, activation=relu)),
                    Dense(num_output_classes)])(scaled_input)

    ce = cross_entropy_with_softmax(z, label)
    pe = classification_error(z, label)

    data_dir = os.path.join(abs_path, "..", "..", "..", "DataSets", "MNIST")

    path = os.path.normpath(os.path.join(data_dir, "Train-28x28_cntk_text.txt"))
    check_path(path)

    reader_train = create_reader(path, True, input_dim, num_output_classes)

    input_map = {
        feature  : reader_train.streams.features,
        label  : reader_train.streams.labels
    }

    # Training config
    minibatch_size = 64
    num_samples_per_sweep = 60000
    num_sweeps_to_train_with = 10

    # Instantiate progress writers.
    #training_progress_output_freq = 100
    progress_writers = [ProgressPrinter(
        #freq=training_progress_output_freq,
        tag='Training',
        num_epochs=num_sweeps_to_train_with)]

    # Instantiate the trainer object to drive the model training
    lr = learning_parameter_schedule_per_sample(1)
    trainer = Trainer(z, (ce, pe), adadelta(z.parameters, lr), progress_writers)

    training_session(
        trainer=trainer,
        mb_source = reader_train,
        mb_size = minibatch_size,
        model_inputs_to_streams = input_map,
        max_samples = num_samples_per_sweep * num_sweeps_to_train_with,
        progress_frequency=num_samples_per_sweep
    ).train()

    # Load test data
    path = os.path.normpath(os.path.join(data_dir, "Test-28x28_cntk_text.txt"))
    check_path(path)

    reader_test = create_reader(path, False, input_dim, num_output_classes)

    input_map = {
        feature  : reader_test.streams.features,
        label  : reader_test.streams.labels
    }

    # Test data for trained model
    C.debugging.start_profiler()
    C.debugging.enable_profiler()
    C.debugging.set_node_timing(True)
    #C.cntk_py.disable_cpueval_optimization() # uncomment this to check CPU eval perf without optimization

    test_minibatch_size = 1024
    num_samples = 10000
    num_minibatches_to_test = num_samples / test_minibatch_size
    test_result = 0.0
    for i in range(0, int(num_minibatches_to_test)):
        mb = reader_test.next_minibatch(test_minibatch_size, input_map=input_map)
        eval_error = trainer.test_minibatch(mb)
        test_result = test_result + eval_error

    C.debugging.stop_profiler()
    trainer.print_node_timing()

    # Average of evaluation errors of all test minibatches
    return test_result / num_minibatches_to_test


from __future__ import print_function
import numpy as np
from cntk.learners import sgd
from cntk.logging import ProgressPrinter
from cntk.layers import Dense, Sequential
import cntk as C

def generate_random_data(sample_size, feature_dim, num_classes):
     # Create synthetic data using NumPy.
     Y = np.random.randint(size=(sample_size, 1), low=0, high=num_classes)

     # Make sure that the data is separable
     X = (np.random.randn(sample_size, feature_dim) + 3) * (Y + 1)
     X = X.astype(np.float32)
     # converting class 0 into the vector "1 0 0",
     # class 1 into vector "0 1 0", ...
     class_ind = [Y == class_number for class_number in range(num_classes)]
     Y = np.asarray(np.hstack(class_ind), dtype=np.float32)
     return X, Y

def ffnet(onnx_net):
    inputs = 2
    outputs = 2
    layers = 2
    hidden_dimension = 50

    np.random.seed(98052)

    # input variables denoting the features and label data
    # features = C.input_variable((inputs), np.float32)
    # label = C.input_variable((outputs), np.float32)

    # Instantiate the feedforward classification model
    net = C.Function.load(onnx_net, format=C.ModelFormat.ONNX)
    # z = net(features)

    # ce = C.cross_entropy_with_softmax(z, label)
    # pe = C.classification_error(z, label)

    # # Instantiate the trainer object to drive the model training
    # lr_per_minibatch = C.learning_parameter_schedule(0.125)
    # progress_printer = C.logging.ProgressPrinter(0)
    # trainer = C.Trainer(z, (ce, pe), [C.learners.sgd(z.parameters, lr=lr_per_minibatch)], [progress_printer])

    # # Get minibatches of training data and perform model training
    # minibatch_size = 25
    # num_minibatches_to_train = 1024

    # aggregate_loss = 0.0
    # for i in range(num_minibatches_to_train):
    #     train_features, labels = generate_random_data(minibatch_size, inputs, outputs)
    #     # Specify the mapping of input variables in the model to actual minibatch data to be trained with
    #     trainer.train_minibatch({features : train_features, label : labels})
    #     sample_count = trainer.previous_minibatch_sample_count
    #     aggregate_loss += trainer.previous_minibatch_loss_average * sample_count

    # last_avg_error = aggregate_loss / trainer.total_number_of_samples_seen

    # test_features, test_labels = generate_random_data(minibatch_size, inputs, outputs)
    # avg_error = trainer.test_minibatch({features : test_features, label : test_labels})
    # print(' error rate on an unseen minibatch: {}'.format(avg_error))

    filename = "model.onnx"
    net.save(filename, format=C.ModelFormat.ONNX)
    data = ""
    with open(filename, 'rb') as f:
     data = f.read()
    return [float(1.0), data]
