import pytest, pandas as pd
from src.run import predict, _features


def test_prediction_format():
    df = pd.DataFrame({_features[0]: "haryana",
           _features[1]: "Groundnut",
           _features[2]: 2026,
           _features[3]: 1234.5,
           _features[4]: 1234.5,
           _features[5]: 123.4,
           _features[6]: 1.23
    })
    result, confidence = predict(df)
    assert result in [0, 1]
    assert type(confidence) == str or confidence == None

def test_prediction_result_0():
    df = pd.DataFrame({_features[0]: "nagaland",
           _features[1]: "Jowar",
           _features[2]: 2006,
           _features[3]: 1000.0,
           _features[4]: 1872.0,
           _features[5]: 1253.2,
           _features[6]: 1.49
    })
    result = predict(df)[0]
    assert result == 0

def test_prediction_result_1():
    df = pd.DataFrame({_features[0]: "haryana",
           _features[1]: "Groundnut",
           _features[2]: 2007,
           _features[3]: 1190.0,
           _features[4]: 446.6,
           _features[5]: 313.7,
           _features[6]: 0.85
    })
    result = predict(df)[0]
    assert result == 1

def test_invalid_df():
    df = pd.DataFrame({_features[0]: "andaman and nicobar islands",
        _features[1]: "Arecanut",
        _features[2]: 2001,
        _features[3]: 4354.0,
        _features[4]: 3080.9,
        _features[5]: 1515.4,
        "Inv": 1.65
    })
    with pytest.raises(ValueError):
        predict(df)
