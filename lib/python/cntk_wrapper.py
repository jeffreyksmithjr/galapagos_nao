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
