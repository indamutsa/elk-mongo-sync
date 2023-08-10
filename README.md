# 🚀 MongoDB Sharded Cluster Synced with Elasticsearch via Monstache 🌍

Data-driven decision making is pivotal in today's era. Having data in MongoDB is great for operational tasks, but when it comes to analytics, search, or visualization, Elasticsearch emerges as a frontrunner. By integrating MongoDB and Elasticsearch, one can extract, index, and visualize data effortlessly. Monstache makes this synchronization seamless.

## Architecture Benefits 🏛️

**1. Real-time Analytics:** With MongoDB handling operational data and Elasticsearch managing analytical data, real-time analytics is a breeze. For instance, a retail company can analyze sales trends as they happen.

**2. Advanced Search Capabilities:** Elasticsearch’s robust full-text search capabilities combined with MongoDB's rich data model offer advanced search features. A content platform can allow users to search for articles, tags, authors, and more with intricate details.

**3. Scalability:** Both MongoDB sharded clusters and Elasticsearch are horizontally scalable. Whether it's expanding product catalogs or accommodating more users, the architecture scales to meet demands.

**4. Visualization:** With Kibana in the mix, visualizing data becomes intuitive. Health sectors could visualize patient records over time, identifying patterns and anomalies.

However, the integration isn't without challenges:

**1. Data Consistency:** As with any distributed system, ensuring data consistency between MongoDB and Elasticsearch is crucial.

**2. Maintenance Overhead:** Running two systems can increase maintenance tasks.

**3. Resource Intensiveness:** Elasticsearch can be resource-intensive, especially when handling large data volumes.

To mitigate these challenges, it's essential to monitor the synchronization process and ensure that both clusters are healthy.

## Repository Structure 🌲

```
❯ tree
.
├── docker-compose.yml                 # Docker Compose configuration
├── k8                                 # Kubernetes configurations
│   ├── 1-es-master.yml                # Elasticsearch master setup
│   ├── 1-mongodb-configservers.yaml   # MongoDB config server setup
│   ├── 2-es-worker1.yml               # Elasticsearch worker 1 setup
│   ├── 2-mongodb-shard1.yaml          # MongoDB shard 1 setup
│   ├── 3-es-worker2.yml               # Elasticsearch worker 2 setup
│   ├── 3-mongodb-shard2.yaml          # MongoDB shard 2 setup
│   ├── 4-logstash.yml                 # Logstash setup for log management
│   ├── 4-mongodb-routers.yaml         # MongoDB routers setup
│   ├── 5-kibana.yml                   # Kibana setup for data visualization
│   ├── 5-setup-rs-job.yaml            # Job to initialize MongoDB replica sets
│   ├── 6-filebeat-daemonset.yml       # Filebeat setup for log shipping
│   ├── 8-monstache-deployment.yaml    # Monstache setup for MongoDB to Elasticsearch sync
│   └── spin-elk-mongo.sh              # Shell script to create all the Kubernetes manifests
└── monstache                          # Monstache configurations
    ├── Dockerfile                     # Docker build instructions for Monstache
    └── monstache.config.toml          # Monstache configuration file
```

## Docker Compose Setup 🐳

### 1. Starting the Cluster 🚀

Boot up MongoDB, Elasticsearch, and Monstache using Docker Compose:

```bash
╰─❯ docker-compose up --build --force-recreate -d
```

### 2. Accessing MongoDB & Elasticsearch 🔗

Connect to MongoDB using MongoDB Compass:

```
mongodb://localhost:27019/mdeforge
```

For Elasticsearch and Kibana access:

```
http://localhost:5601/
```

### 3. Cleaning Up Resources 🧹

To clean up:

```bash
╰─❯ docker-compose down -v --remove-orphans && docker system prune -a --volumes
```

## Kubernetes Setup with `kind` 🌐

### Prerequisites 📚

- `kind` and `kubectl` installed.
- MongoDB Compass for MongoDB GUI interactions.
- Web browser for Kibana access.

### Deployment Steps 🚀

#### 1. Navigate to Kubernetes Configuration Directory

```bash
cd k8
```

#### 2. Run the Initialization Script

We have a shell script that generates all the Kubernetes manifests for the stack. You can also configure it to create the necessary Kubernetes secrets and config maps as you see fit.

```bash
./spin-elk-mongo.sh
```

#### 3. Set Up the `kind` Cluster

```bash
kind delete cluster --name elk-mongo-cluster
kind create cluster --name elk-mongo-cluster
kind config use-context elk-mongo-cluster
```

#### 4. Deploy the Stack

```bash
kubectl apply -f .
```

#### 5. Monitor the Deployment

```bash
watch -n 3 kubectl get po
```

#### 6. Connect to Services

Connect to MongoDB via MongoDB Compass:

In order to connect to the MongoDB cluster, you need to port-forward the MongoDB routers to your local machine:

```bash
kubectl port-forward svc/mongos1 27017
```

Then, connect to MongoDB using MongoDB Compass:

```
mongodb://localhost:27019/mdeforge
```

For Kibana:
For visualizing data, first port-forward the Kibana service to your local machine:

```bash
kubectl port-forward svc/kibana 5601
```

Then, access Kibana via your web browser:

```
http://localhost:5601/
```

GIVE THE CLUSTER A FEW MINUTES TO STABILIZE BEFORE ACCESSING KIBANA.
Oncem you inside kibana, access the Dev Tools and run the following command to create an index pattern:

```bash
GET _cat/indices
```

Then, create an index pattern with the name `monstache*` and select `@timestamp` as the time filter field name.

Now, you can access the Discover tab and visualize the data.
Use this command to see you if mongo sharded cluster and elasticsearch are being synced:

```bash
GET testDb.kittens/_search
```

It should return the first 10 documents from the `kittens` collection.

If there is an issue with the sync, please try to debug the cluster by running the following command. You can also recreate the cluster, and redeploy the stack.

#### Optional: Inspecting the Cluster

```bash
# Pod details
kubectl describe po [POD_NAME]
# Service details
kubectl describe svc [SERVICE_NAME]
# Deployment details
kubectl describe deploy [DEPLOYMENT_NAME]
# View logs
kubectl logs [POD_NAME]
```

## Clean-Up 🧹

```bash
kubectl delete all,secrets,configmaps,pv,pvc --all --all-namespaces
kind delete cluster --name elk-mongo-cluster
```

---

**Congratulations!** 🎉 You've successfully integrated MongoDB with Elasticsearch using Monstache on Kubernetes. Dive deeper and make the most of this powerful combination!
