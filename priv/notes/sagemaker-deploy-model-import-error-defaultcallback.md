%{
    title: "Missing `s3fs` for SageMaker real-time inference tutorial",
    tags: ~w(AWS tip),
    date: "2024-03-31",
}
---
If you're getting the following error when going through a AWS SageMaker Studio tutorial[^1], here's a quick solution I'm writing down, to save someone else searching. It's as obvious as you'd expect!

The error:
```
ModuleNotFoundError: No module named 's3fs'
```

Earlier in the notebook, install the package:

```
%pip install s3fs
```

Then, import it:

```python
import s3fs
```

[^1]: [Deploy a Machine Learning Model to a Real-Time Inference Endpoint](https://aws.amazon.com/tutorials/machine-learning-tutorial-deploy-model-to-real-time-inference-endpoint/)
