import pytest
import time
from pyspark.streaming.kafka import KafkaUtils
from pyspark.sql import Row, SparkSession
from pyspark.sql.functions import col


def get_spark_session(sparkConf):
    if 'sparkSessionSingletonInstance' not in globals():
        globals()['sparkSessionSingletonInstance'] = SparkSession\
            .builder\
            .config(conf=sparkConf)\
            .getOrCreate()
    return globals()['sparkSessionSingletonInstance']


result = []


def count_messages(_, rdd):
    spark = get_spark_session(rdd.context.getConf())

    row_rdd = rdd.map(lambda c: Row(cnt=c))
    count_df = spark.createDataFrame(row_rdd)

    res = count_df.select(col("cnt"))
    result.append(res.first()[0])


@pytest.mark.usefixtures("streaming_context")
@pytest.mark.usefixtures("prime_kafka_pipeline")
def test_message_count(request, streaming_context, prime_kafka_pipeline):
    # GIVEN
    message_count = 9
    prime_kafka_pipeline(topic=request.node.name, msg_count=message_count)

    kafka_stream = \
        KafkaUtils.createDirectStream(
            ssc=streaming_context,
            topics=[request.node.name],
            kafkaParams={
                "metadata.broker.list": "localhost:9092",
                "auto.offset.reset": "smallest",
            }
        )

    # WHEN
    kafka_stream.count().foreachRDD(count_messages)
    streaming_context.start()

    timeout = 10
    start_time = time.time()
    while sum(result) < message_count and time.time() - start_time < timeout:
        time.sleep(0.1)

    # THEN
    assert sum(result) == message_count
