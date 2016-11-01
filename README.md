# Docker build for Apache Spark and Anaconda

This Docker build based on [anaconda3](https://hub.docker.com/r/continuumio/anaconda3/) and [docker-spark](https://github.com/gettyimages/docker-spark).

Use it in a standalone cluster with the accompanying docker-compose.yml, or as a base for more complex recipes.

## What it Gives You
 - Anaconda and Python 3.5
 - XGBoost
 - Apache Spark 2.x
 - [Spark-sklearn](https://github.com/databricks/spark-sklearn)

## Docker example

To run SparkPi, run the image with Docker:

```
docker run --rm -it -p 4040:4040 thuongdinh/docker-spark-anaconda bin/run-example SparkPi 10
```

To start a Jupyter Notebook server with Anaconda from a Docker image:

```
docker run -i -t -p 8888:8888 thuongdinh/docker-spark-anaconda /bin/bash -c "/opt/conda/bin/conda install jupyter -y --quiet && mkdir /opt/notebooks && /opt/conda/bin/jupyter notebook --notebook-dir=/opt/notebooks --ip='*' --port=8888 --no-browser"

```

## License

MIT