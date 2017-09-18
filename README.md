
<!--
Title: Awesome Core ML Models
Description: A curated list of machine learning models in Core ML format.
Author: Kedan Li
-->
<img src="images/coreml.png" width="150" height="150"/>

# Awesome Core ML Models

We've put up the largest collection of machine learning models that work with Apples Core ML standard, to help iOS developers experiment with machine learning techniques. If you've converted a Core ML model and feel free to submit a PR here.

[![Awesome](https://cdn.rawgit.com/sindresorhus/awesome/d7305f38d29fed78fa85652e3a63e154dd8e8829/media/badge.svg)](https://github.com/sindresorhus/awesome)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](http://makeapullrequest.com)

# Models

## Object Detection
*Models that takes image data as input and output useful information about the image.*
* **MobileNet** - Detects the dominant objects present in an image. [Download](https://s3-us-west-2.amazonaws.com/coreml-models/MobileNet.mlmodel) | [Demo](https://github.com/hollance/MobileNet-CoreML) | [Reference](https://arxiv.org/abs/1704.04861)
* **Places CNN** - Detects the scene of an image from 205 categories such as bedroom, forest, coast etc. [Download](https://s3-us-west-2.amazonaws.com/coreml-models/GoogLeNetPlaces.mlmodel) | [Demo](https://github.com/chenyi1989/CoreMLDemo) | [Reference](http://places.csail.mit.edu/index.html)
* **Inception v3** - Detects the dominant objects present in an image. [Download](https://s3-us-west-2.amazonaws.com/coreml-models/Inceptionv3.mlmodel) | [Demo](https://github.com/yulingtianxia/Core-ML-Sample/) | [Reference](https://arxiv.org/abs/1512.00567)
* **ResNet50** - Detects the dominant objects present in an image. [Download](https://s3-us-west-2.amazonaws.com/coreml-models/Resnet50.mlmodel) | [Demo](https://github.com/ytakzk/CoreML-samples) | [Reference](https://arxiv.org/abs/1512.03385)
* **VGG16** - Detects the dominant objects present in an image. [Download](https://s3-us-west-2.amazonaws.com/coreml-models/VGG16.mlmodel) | [Demo](https://github.com/alaphao/CoreMLExample) | [Reference](https://arxiv.org/abs/1409.1556)
* **Car Recognition** - Predict the brand & model of a car. [Download](https://s3-us-west-2.amazonaws.com/coreml-models/CarRecognition.mlmodel) | [Demo](https://github.com/likedan/Core-ML-Car-Recognition) | [Reference](http://mmlab.ie.cuhk.edu.hk/datasets/comp_cars/index.html)
* **YOLO** - Recognize what the objects are inside a given image and where they are in the image. [Download](https://s3-us-west-2.amazonaws.com/coreml-models/TinyYOLO.mlmodel) | [Demo](https://github.com/hollance/YOLO-CoreML-MPSNNGraph) | [Reference](http://machinethink.net/blog/object-detection-with-yolo)
* **AgeNet** - Predict a person's age from one's portrait. [Download](https://s3-us-west-2.amazonaws.com/coreml-models/AgeNet.mlmodel) | [Demo](https://github.com/cocoa-ai/FacesVisionDemo) | [Reference](http://www.openu.ac.il/home/hassner/projects/cnn_agegender/)
* **GenderNet** - Predict a person's gender from one's portrait. [Download](https://s3-us-west-2.amazonaws.com/coreml-models/GenderNet.mlmodel) | [Demo](https://github.com/cocoa-ai/FacesVisionDemo) | [Reference](http://www.openu.ac.il/home/hassner/projects/cnn_agegender/)
* **MNIST** - Predict handwritten (drawn) digits from images. [Download](https://s3-us-west-2.amazonaws.com/coreml-models/MNIST.mlmodel) | [Demo](https://github.com/ph1ps/MNIST-CoreML) | [Reference](http://yann.lecun.com/exdb/mnist/)
* **EmotionNet** - Predict a person's emotion from one's portrait. [Download](https://s3-us-west-2.amazonaws.com/coreml-models/CNNEmotions.mlmodel) | [Demo](https://github.com/cocoa-ai/FacesVisionDemo) | [Reference](http://www.openu.ac.il/home/hassner/projects/cnn_emotions/)
* **SentimentVision** - Predict positive or negative sentiments from images. [Download](https://s3-us-west-2.amazonaws.com/coreml-models/VisualSentimentCNN.mlmodel) | [Demo](https://github.com/cocoa-ai/SentimentVisionDemo) | [Reference](http://www.sciencedirect.com/science/article/pii/S0262885617300355?via%3Dihub)
* **Food101** - Predict the type of foods from images. [Download](https://s3-us-west-2.amazonaws.com/coreml-models/Food101.mlmodel) | [Demo](https://github.com/ph1ps/Food101-CoreML) | [Reference](http://visiir.lip6.fr/explore)
* **Oxford102** - Detect the type of flowers from images. [Download](https://s3-us-west-2.amazonaws.com/coreml-models/Oxford102.mlmodel) | [Demo](https://github.com/cocoa-ai/FlowersVisionDemo) | [Reference](http://jimgoo.com/flower-power/)
* **FlickrStyle** - Detect the artistic style of images. [Download](https://s3-us-west-2.amazonaws.com/coreml-models/FlickrStyle.mlmodel) | [Demo](https://github.com/cocoa-ai/StylesVisionDemo) | [Reference](http://sergeykarayev.com/files/1311.3715v3.pdf)
* **LocationNet** - Predict the location where a picture was taken. [Download](https://s3-us-west-2.amazonaws.com/coreml-models/RN1015k500.mlmodel) | [Demo](https://github.com/awslabs/MXNet2CoreML_iOS_sample_app) | [Reference](https://aws.amazon.com/blogs/ai/estimating-the-location-of-images-using-mxnet-and-multimedia-commons-dataset-on-aws-ec2)

## Style Transfer
*Models that transform image data into other form of image data.*
* **HED** - Output the nested edges of a color image. [Download](https://s3-us-west-2.amazonaws.com/coreml-models/HED_so.mlmodel) | [Demo](https://github.com/s1ddok/HED-CoreML) | [Reference](http://dl.acm.org/citation.cfm?id=2654889)
* **Candy** - Transfer a color image into Candy style. [Download](https://s3-us-west-2.amazonaws.com/coreml-models/FNS-Candy.mlmodel) | [Demo](https://github.com/prisma-ai/torch2coreml) | [Reference](http://cs.stanford.edu/people/jcjohns/eccv16/)
* **Feathers** - Transfer a color image into Feathers style. [Download](https://s3-us-west-2.amazonaws.com/coreml-models/FNS-Feathers.mlmodel) | [Demo](https://github.com/prisma-ai/torch2coreml) | [Reference](http://cs.stanford.edu/people/jcjohns/eccv16/)
* **La Muse** - Transfer a color image into La-muse style. [Download](https://s3-us-west-2.amazonaws.com/coreml-models/FNS-La-Muse.mlmodel) | [Demo](https://github.com/prisma-ai/torch2coreml) | [Reference](http://cs.stanford.edu/people/jcjohns/eccv16/)
* **The Scream** - Transfer a color image into The-Scream style. [Download](https://s3-us-west-2.amazonaws.com/coreml-models/FNS-The-Scream.mlmodel) | [Demo](https://github.com/prisma-ai/torch2coreml) | [Reference](http://cs.stanford.edu/people/jcjohns/eccv16/)
* **Udnie** - Transfer a color image into Udnie style. [Download](https://s3-us-west-2.amazonaws.com/coreml-models/FNS-Udnie.mlmodel) | [Demo](https://github.com/prisma-ai/torch2coreml) | [Reference](http://cs.stanford.edu/people/jcjohns/eccv16/)
* **Mosaic** - Transfer a color image into Mosaic style. [Download](https://s3-us-west-2.amazonaws.com/coreml-models/FNS-Mosaic.mlmodel) | [Demo](https://github.com/prisma-ai/torch2coreml) | [Reference](http://cs.stanford.edu/people/jcjohns/eccv16/)

## Text Analysis
*Models that takes text data as input and output useful information about the text.*
* **Sentiment Polarity** - Predict positive or negative sentiments from sentences. [Download](https://s3-us-west-2.amazonaws.com/coreml-models/SentimentPolarity.mlmodel) | [Demo](https://github.com/cocoa-ai/SentimentCoreMLDemo) | [Reference](http://boston.lti.cs.cmu.edu/classes/95-865-K/HW/HW3/)
* **iMessage Spam Detection** - Detect whether a message is spam. [Download](https://s3-us-west-2.amazonaws.com/coreml-models/MessageClassifier.mlmodel) | [Demo](https://github.com/gkswamy98/imessage-spam-detection/tree/master) | [Reference](http://www.dt.fee.unicamp.br/~tiago/smsspamcollection/)
## Others
* **Exermote** - Predicts the type of exercise from movement data. [Download](https://s3-us-west-2.amazonaws.com/coreml-models/Exermote.mlmodel) | [Demo](https://github.com/Lausbert/Exermote/tree/master/ExermoteInference) | [Reference](http://lausbert.com/2017/08/03/exermote/)


# Supported formats
*List of model formats that could be converted to Core ML with examples*
* [Caffe](https://apple.github.io/coremltools/generated/coremltools.converters.caffe.convert.html)
* [Keras](https://apple.github.io/coremltools/generated/coremltools.converters.keras.convert.html)
* [XGBoost](https://apple.github.io/coremltools/generated/coremltools.converters.xgboost.convert.html)
* [Scikit-learn](https://apple.github.io/coremltools/generated/coremltools.converters.sklearn.convert.html)
* [MXNet](https://aws.amazon.com/blogs/ai/bring-machine-learning-to-ios-apps-using-apache-mxnet-and-apple-core-ml/)
* [LibSVM](https://apple.github.io/coremltools/generated/coremltools.converters.libsvm.convert.html)
* [Torch7](https://github.com/prisma-ai/torch2coreml)

# The Gold
*Collections of machine learning models that could be converted to Core ML*

* [Caffe Model Zoo](https://github.com/BVLC/caffe/wiki/Model-Zoo) - Big list of models in Caffe format.
* [TensorFlow Models](https://github.com/tensorflow/models) - Models for TensorFlow.
* [TensorFlow Slim Models](https://github.com/tensorflow/models/blob/master/slim/README.md) - Another collection of TensorFlow Models.
* [MXNet Model Zoo](https://mxnet.incubator.apache.org/model_zoo/) - Collection of MXNet models.

# Contributing and License
* [See the guide](https://github.com/likedan/Awesome-CoreML-Models/blob/master/.github/CONTRIBUTING.md)
* Distributed under the MIT license. See LICENSE for more information.

