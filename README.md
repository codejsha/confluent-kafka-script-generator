# Confluent Kafka Script Generator

NOTE: This project is no longer maintained. I recommend using the Ansible. (Ansible playbooks for the Confluent Platform: https://github.com/confluentinc/cp-ansible)

The Confluent Kafka Script Generator helps you create scripts(start/stop scripts, properties ...) for Confluent Platform.

## Requirements

- Python 3.7+
- pyyaml
- Jinja2

## Usage

### Value File

Create/Edit configuration file for Kafka cluster:

```yaml
base:
zookeeper:
kafka:
schemaRegistry:
kafkaConnect:
replicator:
kafkaRest:
ksqlDb:
controlCenter:
```

### Run

Execute with default value file (`values.yaml`):

```sh
python generator.py
```

Execute with a specific value file:

```sh
python generator.py values-cluster1.yaml
```
