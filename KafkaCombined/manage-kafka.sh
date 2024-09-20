#!/bin/bash

# Function to display usage information
usage() {
    echo "Usage: $0 [up|down|create-topic|list-topics|describe-topic|produce|consume] [kraft|zookeeper] [additional args...]"
    echo "  up              - Start Kafka cluster"
    echo "  down            - Stop Kafka cluster"
    echo "  create-topic    - Create a new topic"
    echo "  list-topics     - List all topics"
    echo "  describe-topic  - Describe a specific topic"
    echo "  produce         - Produce messages to a topic"
    echo "  consume         - Consume messages from a topic"
    echo "  kraft           - Use KRaft configuration"
    echo "  zookeeper       - Use ZooKeeper configuration"
    exit 1
}

# Check if correct number of arguments is provided
if [ $# -lt 2 ]; then
    usage
fi

# Set the action and configuration based on the arguments
action=$1
case "$2" in
    kraft)
        config="kafka-kraft"
        ;;
    zookeeper)
        config="kafka-zookeeper"
        ;;
    *)
        echo "Invalid configuration: $2"
        usage
        ;;
esac

# Function to start Kafka
start_kafka() {
    echo "Wiping data folders..."
    rm -rf ./vkafka_*
    rm -rf ./vzookeeper

    echo "Recreating empty data folders..."
    mkdir -p vkafka_1 vkafka_2 vkafka_3
    if [ "$config" == "kafka-zookeeper" ]; then
        mkdir -p vzookeeper
    fi

    echo "Starting Kafka with $config configuration..."
    docker-compose -f docker-compose.$config.yml up -d

    if [ $? -eq 0 ]; then
        echo "Kafka cluster is starting up. Use 'docker-compose logs' to view the logs."
        docker-compose -f docker-compose.$config.yml ps
    else
        echo "Failed to start Kafka cluster. Please check the Docker Compose file and try again."
    fi
}

# Function to stop Kafka
stop_kafka() {
    echo "Stopping Kafka with $config configuration..."
    docker-compose -f docker-compose.$config.yml down

    if [ $? -eq 0 ]; then
        echo "Kafka cluster has been stopped."
        
        echo "Removing data folders..."
        rm -rf ./vkafka_*
        if [ "$config" == "kafka-zookeeper" ]; then
            rm -rf ./vzookeeper
        fi
        
        echo "Data folders have been removed."

        echo "Removing dangling volumes..."
        docker volume prune -f
    else
        echo "Failed to stop Kafka cluster. Please check the Docker Compose file and try again."
    fi
}

# Function to create a topic
create_topic() {
    if [ $# -lt 1 ]; then
        echo "Usage: $0 create-topic [kraft|zookeeper] <topic_name> [partitions] [replication-factor]"
        exit 1
    fi
    topic_name=$1
    partitions=${2:-1}
    replication_factor=${3:-1}
    docker-compose -f docker-compose.$config.yml exec kafka-1 kafka-topics.sh --create --topic $topic_name --partitions $partitions --replication-factor $replication_factor --bootstrap-server localhost:9092
}

# Function to list topics
list_topics() {
    docker-compose -f docker-compose.$config.yml exec kafka-1 kafka-topics.sh --list --bootstrap-server localhost:9092
}

# Function to describe a topic
describe_topic() {
    if [ $# -lt 1 ]; then
        echo "Usage: $0 describe-topic [kraft|zookeeper] <topic_name>"
        exit 1
    fi
    topic_name=$1
    docker-compose -f docker-compose.$config.yml exec kafka-1 kafka-topics.sh --describe --topic $topic_name --bootstrap-server localhost:9092
}

# Function to produce messages
produce_messages() {
    if [ $# -lt 1 ]; then
        echo "Usage: $0 produce [kraft|zookeeper] <topic_name>"
        exit 1
    fi
    topic_name=$1
    docker-compose -f docker-compose.$config.yml exec kafka-1 kafka-console-producer.sh --topic $topic_name --bootstrap-server localhost:9092
}

# Function to consume messages
consume_messages() {
    if [ $# -lt 1 ]; then
        echo "Usage: $0 consume [kraft|zookeeper] <topic_name> [--from-beginning]"
        exit 1
    fi
    topic_name=$1
    from_beginning=${2:-""}
    docker-compose -f docker-compose.$config.yml exec kafka-1 kafka-console-consumer.sh --topic $topic_name --bootstrap-server localhost:9092 $from_beginning
}

# Execute the appropriate action
case "$action" in
    up)
        start_kafka
        ;;
    down)
        stop_kafka
        ;;
    create-topic)
        create_topic "${@:3}"
        ;;
    list-topics)
        list_topics
        ;;
    describe-topic)
        describe_topic "${@:3}"
        ;;
    produce)
        produce_messages "${@:3}"
        ;;
    consume)
        consume_messages "${@:3}"
        ;;
    *)
        echo "Invalid action: $action"
        usage
        ;;
esac