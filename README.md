## Kakfa with KRaft

### Commands

Creating topic with replication and partition

```sh
docker-compose exec kafka-1 kafka-topics.sh --create --topic kafka-topic --bootstrap-server localhost:9092 --replication-factor 3 --partitions 3
```

List topics

```sh
docker-compose exec kafka-1 kafka-topics.sh --list --bootstrap-server localhost:9092
```

Describe topics

```sh
docker-compose exec kafka-1 kafka-topics.sh --describe --topic kafka-topic --bootstrap-server localhost:9092
```

Produce message

```sh
docker-compose exec kafka-1 kafka-console-producer.sh --topic my-topic --bootstrap-server localhost:9092
```

Consume message

```sh
docker-compose exec kafka-1 kafka-console-consumer.sh --topic my-topic --from-beginning --bootstrap-server localhost:9092
```

1. `--partition <partition>`: Consume from a specific partition.
2. `--offset <offset>`: Start consuming from a specific offset.
3. `--max-messages <n>`: Consume only n number of messages.
4. `--group <group-id>`: Specify the consumer group ID.
5. `--property print.key=true`: Print the message key along with the value.
6. `--property print.timestamp=true`: Print the message timestamp along with the value.
7. `--property key.separator=<separator>`: Specify a custom separator between key and value.
8. `--timeout-ms <timeout>`: Exit if no message is available for consumption after the specified timeout.
9. `--isolation-level <level>`: Set to "read_committed" to only consume committed messages.
10. `--formatter <class>`: Use a custom message formatter class.
11. `--consumer.config <file>`: Specify a consumer configuration properties file.
12. `--whitelist <regex>`: Consume from all topics matching the specified regular expression.
13. `--max-messages <n>`: Exit after consuming n messages.
14. `--property print.headers=true`: Print message headers.
15. `--property fetch.max.bytes=<n>`: The maximum amount of data the server should return for a fetch request.
