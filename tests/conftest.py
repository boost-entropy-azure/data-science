import pytest
import os
from pyspark import SparkContext
from pyspark.streaming import StreamingContext


@pytest.fixture(scope='session')
def spark_context():
    os.environ['JAVA_HOME'] = '/usr/lib/jvm/java-1.8.0-openjdk-amd64'
    os.environ['PYSPARK_PYTHON'] = '/usr/bin/python3'
    os.environ['PYSPARK_SUBMIT_ARGS'] = \
        '--master local[4] --packages org.apache.spark:spark-streaming-kafka-0-8_2.11:2.4.5 pyspark-shell'
    sc = SparkContext()
    sc.setLogLevel("WARN")
    yield sc
    sc.stop()


@pytest.fixture(scope='session')
def streaming_context(spark_context):
    yield StreamingContext(spark_context, 1)

