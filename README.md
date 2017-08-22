![ICON](.images/coreml.png =200x)

[![Join the chat at https://gitter.im/norio-nomura/SwiftTalkInJapanese](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/Core-ML/Lobby#)
[![Language](https://awesomelinkcounter.herokuapp.com/swift)]()
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](http://makeapullrequest.com)

# Core ML Resources

## Intro
Core ML(https://developer.apple.com/machine-learning/) brings Artificial Intelligence and iOS ever closer. However, there are few Core ML resources and examples currently available. With this repo, we start collecting great CoreML models, examples apps, frameworks and tutorials. If you're working on new cool projects related to Core ML, feel free to pin us on [Gitter Channel](https://gitter.im/Core-ML/Lobby#) to get added here.

## Content
- [Intro](#intro)
- [Models](#Models)
- [Sample Applications](#Sample-Applications)
- [Tutorials](#Tutorials)

## Models
* [Apple](https://developer.apple.com/machine-learning/) Apple provided 6 examples models for Core ML(MobileNet, SqueezeNet, Places205-GoogLeNet, ResNet50, Inception v3, VGG16).
* [YOLO](https://github.com/hollance/YOLO-CoreML-MPSNNGraph) Recognize what the objects are inside a given image and also where they are in the image
* [MNIST](https://github.com/ph1ps/MNIST-CoreML) Predict handwritten (drawn) digits from an image and outputs a prediction from 0-9

## Sample Applications

* [MobileNet with CoreML](https://github.com/hollance/MobileNet-CoreML)
* [Core-ML-Sample](https://github.com/atomic14/VisionCoreMLSample)
* [CoreML-with-ARkit](https://github.com/hanleyweng/CoreML-in-ARKit)

## Tutorials

* [Machine Learning in iOS Using Core ML](https://www.bignerdranch.com/blog/machine-learning-in-ios-using-core-ml/) Went through the entire cycle of generating a CoreML model with python with an example of Linear Regression.
* [Apple CoreML model conversion](http://stsievert.com/blog/2017/06/11/coreml/) How to convert a model to CoreML
* [Core ML and Vision Framework on iOS 11](http://yulingtianxia.com/blog/2017/06/19/Core-ML-and-Vision-Framework-on-iOS-11/)
CoreML overview and reviews in Chinese


# Core ML verson of Scikit Learn Examples

This is a swift 4 implementation of General Examples on Scikit Learn. The data used to generate the Core ML Model is taken from Scikit Learn.

## Compatibility

Core ML require macOS 10.13, iOS 11, or tvOS 11. This example project runs only in iOS 11.

## LinearRegressor

Plotting Cross-Validated Predictions (http://scikit-learn.org/stable/auto_examples/plot_cv_predict.html#sphx-glr-auto-examples-plot-cv-predict-py).

![Screenshot](./images/LinearRegressor.png =300x)

