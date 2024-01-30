This chart installs [Apache ActiveMQ Artemis](https://activemq.apache.org/components/artemis/)

## Docker image
This chart uses a self managed activeMQ Docker Image. To build the Docker image use the following repo containing Dockerfile and other configs.
[ActiveMQ](https://github.com/NashTech-Labs/activemq-docker)

## Usage

[Helm](https://helm.sh) must be installed and initialized to use the charts.
Please refer to Helm's [documentation](https://helm.sh/docs/) to get started.

Once Helm is set up properly, add the repo as follows:

```console
helm install activemq charts/activemq
```

