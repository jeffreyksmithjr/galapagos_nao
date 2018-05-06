import numpy as np
import mxnet as mx
from mxnet import nd, autograd, gluon

data_ctx = mx.cpu()
model_ctx = mx.cpu()

# Basic layers
def dense(n, act_type):
    act_type_str = act_type.decode("UTF-8")
    if act_type_str == "none":
        act_type_str = None
    return gluon.nn.Dense(n, activation=act_type_str)

def activation(act_type):
    return gluon.nn.Activation(act_type.decode("UTF-8"))

def dropout(rate):
    return gluon.nn.Dropout(rate)

def batch_norm():
    return gluon.nn.BatchNorm()

def leaky_relu(alpha):
    return gluon.nn.LeakyReLU(alpha=alpha)

def flatten():
    return gluon.nn.Flatten()

# Build the network
def build(layers):
    net = gluon.nn.Sequential()
    with net.name_scope():
        for layer in layers:
            net.add(layer)
    return net

# Transform the data
def transform(data, label):
    return data.astype(np.float32)/255, label.astype(np.float32)

# Evaluate model accuracy
def evaluate_accuracy(data_iterator, net):
    acc = mx.metric.Accuracy()
    for i, (data, label) in enumerate(data_iterator):
        data = data.as_in_context(model_ctx).reshape((-1, 784))
        label = label.as_in_context(model_ctx)
        output = net(data)
        predictions = nd.argmax(output, axis=1)
        acc.update(preds=predictions, labels=label)
    return acc.get()[1]


def run(net):
    epochs = 1 # Should be 10 or more

    batch_size = 64
    num_examples = 60000

    train_data = mx.gluon.data.DataLoader(mx.gluon.data.vision.MNIST(train=True, transform=transform),
                                          batch_size, shuffle=True)
    test_data = mx.gluon.data.DataLoader(mx.gluon.data.vision.MNIST(train=False, transform=transform),
                                     batch_size, shuffle=False)

    net.collect_params().initialize(mx.init.Normal(sigma=.1), ctx=model_ctx)
    softmax_cross_entropy = gluon.loss.SoftmaxCrossEntropyLoss()
    trainer = gluon.Trainer(net.collect_params(), 'sgd', {'learning_rate': .01})

    test_accuracy = 0.0

    for e in range(epochs):
        cumulative_loss = 0
        for i, (data, label) in enumerate(train_data):
            data = data.as_in_context(model_ctx).reshape((-1, 784))
            label = label.as_in_context(model_ctx)
            with autograd.record():
                output = net(data)
                loss = softmax_cross_entropy(output, label)
            loss.backward()
            trainer.step(data.shape[0])
            cumulative_loss += nd.sum(loss).asscalar()

        test_accuracy = evaluate_accuracy(test_data, net)
        train_accuracy = evaluate_accuracy(train_data, net)
        print("Epoch %s. Loss: %s, Train_acc %s, Test_acc %s" %
              (e, cumulative_loss/num_examples, train_accuracy, test_accuracy))

    return [net(mx.sym.var('data')).tojson(), net.collect_params(), float(test_accuracy)]

def print_net(net):
    return net.__str__()