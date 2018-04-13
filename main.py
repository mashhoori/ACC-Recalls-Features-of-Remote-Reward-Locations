import numpy as np
from sklearn import preprocessing
from keras.models import Sequential
from keras.layers.core import Dense, Dropout, Activation, Flatten
from keras.layers.convolutional import Convolution2D, MaxPooling2D
from keras.layers.recurrent import SimpleRNN
from keras.optimizers import SGD, Adam
from keras.utils import np_utils
from keras.layers.advanced_activations import LeakyReLU, PReLU
from matplotlib.colors import LogNorm
import matplotlib.pyplot as plt
import scipy
import scipy.io
import pandas as pd
from keras.layers.normalization import BatchNormalization
from keras.callbacks import EarlyStopping
import sys
import pickle
from keras import backend as K

class NNModel:

    def __init__(self):
        self.model = None
        self.numInput = None
        self.getLayerOutput = [None] * 4

    ###########################################################

    def GetLayersOutput(self, x): 
        res = [x] 
        for i in range(4):
            res += [self.getLayerOutput[i]([x, 0])[0]]
        
        return res

    ###########################################################

    def SaveWeights(self, path):
        d = {'w':self.model.get_weights(), 'numInput': self.numInput}
        with open(path, 'wb') as handle:
            pickle.dump(d, handle)

    ###########################################################

    def LoadWeights(self, path): 

        with open(path, 'rb') as handle:
            d = pickle.load(handle)

        w = d['w']
        self.numInput = d['numInput']

        self.CreateModel()
        self.model.set_weights(w)        

    ###########################################################   

    def Predict(self, X):
        return self.model.predict(X)

    ###########################################################

    def Train(self, X_train, Y_train, X_val, Y_val):

        if(self.model is None):
            self.numInput = X_train.shape[1]
            self.CreateModel()

        batch_size = 200
        nb_epoch   = 100    

        callbacks = [
        EarlyStopping(monitor='val_loss', patience=75, verbose=0)    
        ]

        self.model.fit(X_train, Y_train, batch_size=batch_size, epochs=nb_epoch,
                   verbose=1, validation_data=(X_val, Y_val), callbacks=callbacks)     

    ###########################################################

    def CreateModel(self):

        model = Sequential() 

        model.add(Dense(100, input_shape = [self.numInput] )) 
        #model.add(BatchNormalization())
        model.add(Activation('relu'))        
        #model.add(Dropout(0.5))  
        
        model.add(Dense(50))
        #model.add(BatchNormalization())
        model.add(Activation('relu'))      
        #model.add(Dropout(0.5))
        
        model.add(Dense(25))
        #model.add(BatchNormalization())
        model.add(Activation('tanh'))        
        
        model.add(Dense(2))
        model.add(Activation('linear'))        
        
        selectedLayers = [1, 3, 5, -1]
        
        for i in range(len(selectedLayers)):
            self.getLayerOutput[i] = K.function([model.layers[0].input, K.learning_phase()], [model.layers[selectedLayers[i]].output])
     

        ad = SGD(lr=0.0001, decay=0e-6, momentum=0.9, nesterov=True)
        #ad = Adam(lr=0.001, beta_1=0.9, beta_2=0.999, epsilon=1e-08, decay=0.001)
        model.compile(loss='mean_squared_error', optimizer=ad)    

        self.model  = model


###########################################################
###########################################################
    
    
#def GetResult(model, inputD):
#    get_activations = theano.function([model.layers[0].input], model.layers[-1].get_output(train=False), allow_input_downcast=True)
#    results = get_activations(inputD)
#    return results 


def CreateObjectArray(data):
    
    obj_arr = np.zeros((len(data),), dtype=np.object)
    for i in range(len(data)):
        obj_arr[i] = data[i]

    return obj_arr    



if __name__ == '__main__':
    trainAndSave = sys.argv[1] == 'True'
#    filePath  = sys.argv[2]
    
    nnModel = NNModel()
    
    if(trainAndSave):    

        data = scipy.io.loadmat(r'E:\Proj\Scripts\data.mat')
        train = data['train'].T
        valid = data['test'].T
        loc_t = data['train_loc'].T
        loc_v = data['test_loc'].T
        
        nnModel.Train(train, loc_t, valid, loc_v)
        
        resValid = nnModel.GetLayersOutput(valid)
        resTrain = nnModel.GetLayersOutput(train)        
#        res = nnModel.Predict(valid)
#        res2 = nnModel.Predict(train)        

        #scipy.io.savemat(r'E:\Proj\Scripts\data_out.mat', {'resValid_0': resValid[0], 'resValid_1': resValid[1],'resValid_2': resValid[2],'resValid_3': resValid[3],'resTrain_0': resTrain[0], 'resTrain_1': resTrain[1],'resTrain_2': resTrain[2],'resTrain_3': resTrain[3]})
        scipy.io.savemat(r'E:\Proj\Scripts\data_out.mat', {'resValid': CreateObjectArray(resValid), 'resTrain': CreateObjectArray(resTrain)})

  #      nnModel.SaveWeights(filePath)
        
    else:
        
        nnModel.LoadWeights(filePath)
        data = scipy.io.loadmat(r'E:\Proj\Scripts\data.mat')        
        valid = data['validN'].T
        resValid = nnModel.GetLayersOutput(valid)
#        res = nnModel.Predict(valid)
        scipy.io.savemat(r'E:\Proj\Scripts\data_out.mat', {'resValid': CreateObjectArray(resValid), 'resTrain': []})
#        scipy.io.savemat(r'E:\Proj\Scripts\data_out.mat', {'resValid_0': resValid[0], 'resValid_1': resValid[1],'resValid_2': resValid[2],'resValid_3': resValid[3], 'res2': []})
        
        
        
        
        
        
        
        
        
#scipy.io.savemat(r'C:\Users\a.mashhoori\Desktop\Proj\Scripts\weights.mat', {'w': model.get_weights()})
#scipy.io.savemat(r'C:\Users\a.mashhoori\Desktop\Proj\Scripts\weight_out.mat', {'res': model.get_weights()})