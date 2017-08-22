//
//  ViewController.swift
//  LinearRegressor
//
//  Created by Li Kedan on 8/22/17.
//  Copyright © 2017 Thywis inc. All rights reserved.
//

import UIKit
import CoreML

class ViewController: UIViewController {

    let scatterView = ScatterView()
    
    var X = [[Double]]()
    var y = [Double]()
    var predictions = [Double]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let path = Bundle.main.path(forResource: "plot_cv_predict", ofType: ".plist"), let data = NSDictionary(contentsOfFile: path) {
            X = data["X"] as! [[Double]]
            y = data["y"] as!  [Double]
        }
        
        var XMLArray = [MLMultiArray]()
        for feature in X {
            guard let mlMultiArray = try? MLMultiArray(shape:[13,1], dataType: MLMultiArrayDataType.double) else {
                fatalError("Unexpected runtime error. MLMultiArray")
            }
            for index in 0...feature.count - 1 {
                mlMultiArray[index] = NSNumber(floatLiteral: feature[index])
            }
            XMLArray.append(mlMultiArray)
        }
        
        do {
            let model = PlotCVPredict().model
            for feature in XMLArray {
                let result = try model.prediction(from: PlotCVPredictInput(input: feature))
                if let prediction = result.featureValue(for: "prediction")?.doubleValue {
                    predictions.append(prediction)
                }
            }
            
            for index in 0...predictions.count - 1 {
                print(predictions[index], y[index])
            }
        } catch {
            fatalError("can't load Vision ML model: \(error)")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        scatterView.renderWithData(x: predictions, y: y, frame: view.frame)
        if let chart = scatterView.chart?.view {
            view.addSubview(chart)
        }
    }

}

