import numpy as np
import mxnet as mx
from mxnet import nd, autograd, gluon

data_ctx = mx.cpu()
model_ctx = mx.cpu()

batch_size = 64
num_inputs = 784
num_outputs = 10
num_examples = 60000

def transform(data, label):
    return data.astype(np.float32)/255, label.astype(np.float32)

train_data = mx.gluon.data.DataLoader(mx.gluon.data.vision.MNIST(train=True, transform=transform),
                                      batch_size, shuffle=True)
test_data = mx.gluon.data.DataLoader(mx.gluon.data.vision.MNIST(train=False, transform=transform),
                                     batch_size, shuffle=False)

num_hidden = 64

def dense(n):
    return gluon.nn.Dense(n)

def dense_relu(n):
    return gluon.nn.Dense(n, activation="relu")

def build(layers):
    net = gluon.nn.Sequential()
    with net.name_scope():
        for layer in layers:
            net.add(layer)
    return net
    # net.add(gluon.nn.Dense(num_hidden, activation="relu"))
    # net.add(gluon.nn.Dense(num_hidden, activation="relu"))
    # net.add(gluon.nn.Dense(num_outputs))



def evaluate_accuracy(data_iterator, net):
    acc = mx.metric.Accuracy()
    for i, (data, label) in enumerate(data_iterator):
        data = data.as_in_context(model_ctx).reshape((-1, 784))
        label = label.as_in_context(model_ctx)
        output = net(data)
        predictions = nd.argmax(output, axis=1)
        acc.update(preds=predictions, labels=label)
    return acc.get()[1]

epochs = 1
smoothing_constant = .01

def run(net):
    net.collect_params().initialize(mx.init.Normal(sigma=.1), ctx=model_ctx)
    softmax_cross_entropy = gluon.loss.SoftmaxCrossEntropyLoss()
    trainer = gluon.Trainer(net.collect_params(), 'sgd', {'learning_rate': .01})

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

    return net

def print_net(net):
    return net.__str__()