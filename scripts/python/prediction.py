import numpy as np
import pandas as pd

# Models
from sklearn.ensemble import RandomForestRegressor, GradientBoostingRegressor
from sklearn.model_selection import train_test_split, GridSearchCV
from sklearn.pipeline import make_pipeline
from sklearn.metrics import r2_score, mean_squared_error, explained_variance_score

df_train = pd.read_csv('./temp/prediction/train.csv')

y = df_train["D0"]
X = df_train.drop("D0", axis=1)

X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0, random_state=0)

pipelines = {
    "rf": make_pipeline(RandomForestRegressor(random_state=0)),
    "gb": make_pipeline(GradientBoostingRegressor(random_state=0))
}

rf_hyperparameters = {
    "randomforestregressor__n_estimators": [1000],
    "randomforestregressor__criterion": ['mse'],
    "randomforestregressor__max_features": [1, 2, 3],
    'randomforestregressor__min_samples_leaf': [1, 2, 3]
}
gb_hyperparameters = {
    "gradientboostingregressor__n_estimators": [25, 50, 75, 100, 125],
    'gradientboostingregressor__learning_rate': [0.05],
    'gradientboostingregressor__max_depth': [6, 8, 10, 12, 14, 16],
    'gradientboostingregressor__min_samples_leaf': [2, 4, 6, 8, 10, 12],
    'gradientboostingregressor__max_features': [1, 2, 3]
}
hyperparameters = {"rf": rf_hyperparameters,
                   "gb": gb_hyperparameters}

# Create empty dictionary called fitted_models
fitted_models = {}

# Loop through model pipelines, tuning each one and saving it to fitted_models
for name, pipeline in pipelines.items():
    # Create cross-validation object from pipeline and hyperparameters
    model = GridSearchCV(
        pipeline, hyperparameters[name], cv=10, n_jobs=5, verbose=1, scoring='r2', refit=True)

    model.fit(X_train, y_train)

    fitted_models[name] = model

X_pred = pd.read_csv('./temp/prediction/pred.csv')
y_pred = (fitted_models['rf'].predict(X_pred) +
          fitted_models['gb'].predict(X_pred)) / 2
np.savetxt('./temp/prediction/predicted.csv', y_pred, delimiter=',')
