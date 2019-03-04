import json

with open('content.json', 'r') as f:
    data = json.load(f)

model_metadata = {}
for type in data["types"]:
    model_metadata[type] = []

for model in data["models"]:
    model_metadata[model["type"]].append(model)

def render_model_line(model):
    return "* **" + model["name"] + "** - " + model["description"] + " [Download](" + model["download_link"] + ") | [Demo](" + model["demo_link"] + ") | [Reference](" + model["reference_link"] + ")\n"

content = """

<!--
Title: Awesome Core ML Models
Description: A curated list of machine learning models in Core ML format.
Author: Kedan Li
-->
<p align="center">
<img src="images/coreml.png" width="329" height="295"/>
</p>


Since iOS 11, Apple released Core ML framework to help developers integrate machine learning models into applications. [The official documentation](https://developer.apple.com/documentation/coreml)

We've put up the largest collection of machine learning models in Core ML format, to help  iOS, macOS, tvOS, and watchOS developers experiment with machine learning techniques.

If you've converted a Core ML model, feel free to submit a [pull request](https://github.com/likedan/Awesome-CoreML-Models/compare).

Recently, we've included visualization tools. And here's one [Netron](https://lutzroeder.github.io/Netron).

[![Awesome](https://cdn.rawgit.com/sindresorhus/awesome/d7305f38d29fed78fa85652e3a63e154dd8e8829/media/badge.svg)](https://github.com/sindresorhus/awesome)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](http://makeapullrequest.com)

# Models

## Image - Metadata/Text
*Models that takes image data as input and output useful information about the image.*
"""

for model in model_metadata["image"]:
    content += render_model_line(model)

content += """

## Image - Image
*Models that transform image.*
"""

for model in model_metadata["image-image"]:
    content += render_model_line(model)

content += """

## Text - Metadata/Text
*Models that process text data*
"""

for model in model_metadata["text"]:
    content += render_model_line(model)

content += "## Miscellaneous\n"

for model in model_metadata["miscellaneous"]:
    content += render_model_line(model)

content += """

# Visualization Tools
*Tools that helps visualize CoreML Models*
* [Netron](https://lutzroeder.github.io/Netron)

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
* [TensorFlow Slim Models](https://github.com/tensorflow/models/tree/master/research/slim/README.md) - Another collection of TensorFlow Models.
* [MXNet Model Zoo](https://mxnet.incubator.apache.org/model_zoo/) - Collection of MXNet models.

*Individual machine learning models that could be converted to Core ML. We'll keep adjusting the list as they become converted.*
* [LaMem](https://github.com/MiyainNYC/Visual-Memorability-through-Caffe) Score the memorability of pictures.
* [ILGnet](https://github.com/BestiVictory/ILGnet) The aesthetic evaluation of images.
* [Colorization](https://github.com/richzhang/colorization) Automatic colorization using deep neural networks.
* [Illustration2Vec](https://github.com/rezoo/illustration2vec) Estimating a set of tags and extracting semantic feature vectors from given illustrations.
* [CTPN](https://github.com/tianzhi0549/CTPN) Detecting text in natural image.
* [Image Analogy](https://github.com/msracver/Deep-Image-Analogy) Find semantically-meaningful dense correspondences between two input images.
* [iLID](https://github.com/twerkmeister/iLID) Automatic spoken language identification.
* [Fashion Detection](https://github.com/liuziwei7/fashion-detection) Cloth detection from images.
* [Saliency](https://github.com/imatge-upc/saliency-2016-cvpr) The prediction of salient areas in images has been traditionally addressed with hand-crafted features.
* [Face Detection](https://github.com/DolotovEvgeniy/DeepPyramid) Detect face from image.
* [mtcnn](https://github.com/CongWeilin/mtcnn-caffe) Joint Face Detection and Alignment.
* [deephorizon](https://github.com/scottworkman/deephorizon) Single image horizon line estimation.

# Contributing and License
* [See the guide](https://github.com/likedan/Awesome-CoreML-Models/blob/master/.github/CONTRIBUTING.md)
* Distributed under the MIT license. See LICENSE for more information.
"""

with open("README.md", 'w') as out:
    out.write(content + '\n')
