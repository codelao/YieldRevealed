import sys, json, pandas as pd
from pathlib import Path
from . import __config__

_model_path = Path(__config__.__path__) / "models" / "random-forest-plus-encoder.pkl"
_features = [
    "State",
    "Crop",
    "Year",
    "Annual",
    "Monsoon",
    "PrevYearYield"
]

def predict(df: pd.DataFrame) -> tuple[int, str]:
    missing = [col for col in _features if col not in df.columns]
    if missing: raise ValueError(f"Missing features: {missing}")

    X = df[_features]

    import pickle
    with open(_model_path, "rb") as f: pipeline = pickle.load(f)

    y_pred = pipeline.predict(X)

    if hasattr(pipeline, "predict_proba"):
        probabilities = pipeline.predict_proba(X)
        c = probabilities.max() * 100
        confidence = f"{c:.2f}%"
    else:
        confidence = None

    if y_pred[0] == 1: return 1, confidence
    return 0, confidence

def main() -> tuple[int, str]:
    df = pd.DataFrame([{_features[0]: sys.argv[1],
           _features[1]: sys.argv[2],
           _features[2]: int(sys.argv[3]),
           _features[3]: float(sys.argv[4]),
           _features[4]: float(sys.argv[5]),
           _features[5]: float(sys.argv[6])
    }])

    return predict(df)

    


if __name__ == "__main__":
    if len(sys.argv) == 7:
        prediction, confidence = main()
        print(json.dumps({"target_prediction": prediction,
                          "confidence": confidence
                          }))
        sys.exit(0)
    else:
        sys.exit(1)
