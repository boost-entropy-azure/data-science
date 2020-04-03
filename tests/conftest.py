import pytest
import os
from pyspark import SparkContext
from pyspark.streaming import StreamingContext
from kafka import KafkaProducer
from kafka.admin import KafkaAdminClient


@pytest.fixture(scope='session')
def spark_context():
    os.environ['JAVA_HOME'] = '/usr/lib/jvm/java-1.8.0-openjdk-amd64'
    os.environ['PYSPARK_PYTHON'] = '/usr/bin/python3'
    os.environ['PYSPARK_SUBMIT_ARGS'] = \
        '--master local[4] --packages org.apache.spark:spark-streaming-kafka-0-8_2.11:2.4.5 pyspark-shell'
    sc = SparkContext()
    sc.setLogLevel('ERROR')
    yield sc
    sc.stop()


@pytest.fixture(scope='session')
def streaming_context(spark_context):
    yield StreamingContext(spark_context, 1)


@pytest.fixture(scope='function')
def prime_kafka_pipeline():
    _topic = ''

    def _prime(topic, msg_count):
        nonlocal _topic
        _topic = topic
        messenger = KafkaProducer(bootstrap_servers=['localhost:9092'])
        for idx in range(msg_count):
            messenger.send(topic=topic, value='{} message {}'.format(topic, idx).encode())

    yield _prime
    admin_client = KafkaAdminClient(bootstrap_servers='localhost:9092')
    admin_client.delete_topics([_topic])
