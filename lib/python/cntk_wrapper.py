from __future__ import print_function
import numpy as np
import os
import sys
import time
from itertools import izip

import cntk as C
import cntk.tests.test_utils
C.cntk_py.set_fixed_random_seed(1) # fix a random seed for CNTK components

# Read a CTF formatted text (as mentioned above) using the CTF deserializer from a file
def create_reader(path, is_training, input_dim, num_label_classes):
    
    ctf = C.io.CTFDeserializer(path, C.io.StreamDefs(
          labels=C.io.StreamDef(field='labels', shape=num_label_classes, is_sparse=False),
          features=C.io.StreamDef(field='features', shape=input_dim, is_sparse=False)))
                          
    return C.io.MinibatchSource(ctf,
        randomize = is_training, max_sweeps = C.io.INFINITELY_REPEAT if is_training else 1)

def evaluate(onnx_net_path):
    z = C.Function.load(onnx_net_path, format=C.ModelFormat.ONNX)

    out = C.softmax(z)

    input_dim_model = (1, 28, 28) 
    input_dim = 28*28 # used by readers to treat input data as a vector
    num_output_classes = 10

    # Read the data for evaluation
    data_dir = os.path.join("resources", "data", "MNIST")
    test_file=os.path.join(data_dir, "Test-28x28_cntk_text.txt")
    reader_eval=create_reader(test_file, False, input_dim, num_output_classes)

    x = C.input_variable(input_dim_model)
    y = C.input_variable(num_output_classes)

    eval_minibatch_size = 25
    eval_input_map = {x: reader_eval.streams.features, y:reader_eval.streams.labels} 

    data = reader_eval.next_minibatch(eval_minibatch_size, input_map=eval_input_map)

    img_label = data[y].asarray()
    img_data = data[x].asarray()

    # reshape img_data to: M x 1 x 28 x 28 to be compatible with model
    img_data = np.reshape(img_data, (eval_minibatch_size, 1, 28, 28))

    predicted_label_prob = [out.eval(img_data[i]) for i in range(len(img_data))]

    # Find the index with the maximum value for both predicted as well as the ground truth
    pred = [np.argmax(predicted_label_prob[i]) for i in range(len(predicted_label_prob))]
    gtlabel = [np.argmax(img_label[i]) for i in range(len(img_label))]

    truth_labels = gtlabel[:25]
    print("Label    :", truth_labels)
    print("Predicted:", pred)

    error_rate = sum(chr1 != chr2 for chr1, chr2 in izip(truth_labels, pred)) / float(len(pred))
    return error_rate.item()

