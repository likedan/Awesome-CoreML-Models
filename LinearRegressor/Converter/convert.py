import coremltools

import plot_cv_predict

# plot_cv_predict.save_data()

model = plot_cv_predict.train()
coreml_model = coremltools.converters.sklearn.convert(model, input_features=["Double List"], output_feature_names=["Double"])
coreml_model.save('plot_cv_predict.mlmodel')
