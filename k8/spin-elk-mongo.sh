#!/bin/bash

sudo rm -rf ../mongo-bundle

cat << EOF > 8-monstache-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: monstache-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: monstache
  template:
    metadata:
      labels:
        app: monstache
    spec:
      containers:
      - name: monstache
        image: indamutsa/monstache:v1.0.0
        args: 
        - "-f"
        - "/app/monstache.config.toml"
        ports:
        - containerPort: 8080
        livenessProbe:
          httpGet:
            path: /healthz
            port: 8080
          initialDelaySeconds: 1
          periodSeconds: 1
          timeoutSeconds: 30
          failureThreshold: 300
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"

      restartPolicy: Always

---

apiVersion: v1
kind: Service
metadata:
  name: monstache
spec:
  selector:
    app: monstache
  ports:
    - protocol: TCP
      port: 8080
      targetPort: 8080
  type: ClusterIP

EOF

echo "Kubernetes manifests written to monstache-deployment.yaml"



cat <<EOF > 1-mongodb-configservers.yaml
# Config server replica set 1
apiVersion: v1
kind: Service
metadata:
  name: mongocfg1
  labels:
    app: mongocfg1
spec:
  ports:
  - port: 27017
    targetPort: 27017
  selector:
    app: mongocfg1
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mongocfg1
spec:
  serviceName: "mongocfg1"
  replicas: 1
  selector:
    matchLabels:
      app: mongocfg1
  template:
    metadata:
      labels:
        app: mongocfg1
    spec:
      containers:
      - name: mongocfg1
        image: indamutsa/mongo:v1.0.0
        command:
        - mongod
        - --configsvr
        - --replSet
        - mongors1conf
        - --dbpath
        - /data/db
        - --port
        - "27017"
        - --bind_ip_all
        ports:
        - containerPort: 27017
        env:
        - name: TERM
          value: xterm
        volumeMounts:
        - name: mongodb-config-data
          mountPath: /data/db
  volumeClaimTemplates:
  - metadata:
      name: mongodb-config-data
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 1Gi
---

# Config server replica set 2
apiVersion: v1
kind: Service
metadata:
  name: mongocfg2
  labels:
    app: mongocfg2
spec:
  ports:
  - port: 27017
    targetPort: 27017
  selector:
    app: mongocfg2
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mongocfg2
spec:
  serviceName: "mongocfg2"
  replicas: 1
  selector:
    matchLabels:
      app: mongocfg2
  template:
    metadata:
      labels:
        app: mongocfg2
    spec:
      containers:
      - name: mongocfg2
        image: indamutsa/mongo:v1.0.0
        command:
        - mongod
        - --configsvr
        - --replSet
        - mongors1conf
        - --dbpath
        - /data/db
        - --port
        - "27017"
        - --bind_ip_all
        ports:
        - containerPort: 27017
        env:
        - name: TERM
          value: xterm
        volumeMounts:
        - name: mongodb-config-data
          mountPath: /data/db
  volumeClaimTemplates:
  - metadata:
      name: mongodb-config-data
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 1Gi
---
# Config server replica set 3
apiVersion: v1
kind: Service
metadata:
  name: mongocfg3
  labels:
    app: mongocfg3
spec:
  ports:
  - port: 27017
    targetPort: 27017
  selector:
    app: mongocfg3
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mongocfg3
spec:
  serviceName: "mongocfg3"
  replicas: 1
  selector:
    matchLabels:
      app: mongocfg3
  template:
    metadata:
      labels:
        app: mongocfg3
    spec:
      containers:
      - name: mongocfg3
        image: indamutsa/mongo:v1.0.0
        command:
        - mongod
        - --configsvr
        - --replSet
        - mongors1conf
        - --dbpath
        - /data/db
        - --port
        - "27017"
        - --bind_ip_all
        ports:
        - containerPort: 27017
        env:
        - name: TERM
          value: xterm
        volumeMounts:
        - name: mongodb-config-data
          mountPath: /data/db
  volumeClaimTemplates:
  - metadata:
      name: mongodb-config-data
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 1Gi
EOF

echo "Kubernetes manifests written to mongodb-configservers.yaml"


#!/bin/bash

cat <<EOF > 2-mongodb-shard1.yaml
# Replica Set 1
apiVersion: v1
kind: Service
metadata:
  name: mongors1n1
  labels:
    app: mongors1n1
spec:
  ports:
  - port: 27017
    targetPort: 27017
  selector:
    app: mongors1n1
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mongors1n1
spec:
  serviceName: "mongors1n1"
  replicas: 1
  selector:
    matchLabels:
      app: mongors1n1
  template:
    metadata:
      labels:
        app: mongors1n1
    spec:
      containers:
      - name: mongors1n1
        image: indamutsa/mongo:v1.0.0
        command:
        - mongod
        - --shardsvr
        - --replSet
        - mongors1
        - --dbpath
        - /data/db
        - --port
        - "27017"
        - --bind_ip_all
        ports:
        - containerPort: 27017
        env:
        - name: TERM
          value: xterm
        volumeMounts:
        - name: mongodb-data
          mountPath: /data/db
  volumeClaimTemplates:
  - metadata:
      name: mongodb-data
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 1Gi
# Replica 2          
---
apiVersion: v1
kind: Service
metadata:
  name: mongors1n2
  labels:
    app: mongors1n2
spec:
  ports:
  - port: 27017
    targetPort: 27017
  selector:
    app: mongors1n2
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mongors1n2
spec:
  serviceName: "mongors1n2"
  replicas: 1
  selector:
    matchLabels:
      app: mongors1n2
  template:
    metadata:
      labels:
        app: mongors1n2
    spec:
      containers:
      - name: mongors1n2
        image: indamutsa/mongo:v1.0.0
        command:
        - mongod
        - --shardsvr
        - --replSet
        - mongors1
        - --dbpath
        - /data/db
        - --port
        - "27017"
        - --bind_ip_all
        ports:
        - containerPort: 27017
        env:
        - name: TERM
          value: xterm
        volumeMounts:
        - name: mongodb-data
          mountPath: /data/db
  volumeClaimTemplates:
  - metadata:
      name: mongodb-data
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 1Gi
       
---
# Replica Set 3  
apiVersion: v1
kind: Service
metadata:
  name: mongors1n3
  labels:
    app: mongors1n3
spec:
  ports:
  - port: 27017
    targetPort: 27017
  selector:
    app: mongors1n3
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mongors1n3
spec:
  serviceName: "mongors1n3"
  replicas: 1
  selector:
    matchLabels:
      app: mongors1n3
  template:
    metadata:
      labels:
        app: mongors1n3
    spec:
      containers:
      - name: mongors1n3
        image: indamutsa/mongo:v1.0.0
        command:
        - mongod
        - --shardsvr
        - --replSet
        - mongors1
        - --dbpath
        - /data/db
        - --port
        - "27017"
        - --bind_ip_all
        ports:
        - containerPort: 27017
        env:
        - name: TERM
          value: xterm
        volumeMounts:
        - name: mongodb-data
          mountPath: /data/db
  volumeClaimTemplates:
  - metadata:
      name: mongodb-data
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 1Gi

EOF

echo "Kubernetes manifests written to mongodb-shard1.yaml"


#!/bin/bash

cat <<EOF > 3-mongodb-shard2.yaml
# Replica Set 1
apiVersion: v1
kind: Service
metadata:
  name: mongors2n1
  labels:
    app: mongors2n1
spec:
  ports:
  - port: 27017
    targetPort: 27017
  selector:
    app: mongors2n1
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mongors2n1
spec:
  serviceName: "mongors2n1"
  replicas: 1
  selector:
    matchLabels:
      app: mongors2n1
  template:
    metadata:
      labels:
        app: mongors2n1
    spec:
      containers:
      - name: mongors2n1
        image: indamutsa/mongo:v1.0.0
        command:
        - mongod
        - --shardsvr
        - --replSet
        - mongors2
        - --dbpath
        - /data/db
        - --port
        - "27017"
        - --bind_ip_all
        ports:
        - containerPort: 27017
        env:
        - name: TERM
          value: xterm
        volumeMounts:
        - name: mongodb-data
          mountPath: /data/db
  volumeClaimTemplates:
  - metadata:
      name: mongodb-data
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 1Gi
# Replica 2          
---
apiVersion: v1
kind: Service
metadata:
  name: mongors2n2
  labels:
    app: mongors2n2
spec:
  ports:
  - port: 27017
    targetPort: 27017
  selector:
    app: mongors2n2
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mongors2n2
spec:
  serviceName: "mongors2n2"
  replicas: 1
  selector:
    matchLabels:
      app: mongors2n2
  template:
    metadata:
      labels:
        app: mongors2n2
    spec:
      containers:
      - name: mongors2n2
        image: indamutsa/mongo:v1.0.0
        command:
        - mongod
        - --shardsvr
        - --replSet
        - mongors2
        - --dbpath
        - /data/db
        - --port
        - "27017"
        - --bind_ip_all
        ports:
        - containerPort: 27017
        env:
        - name: TERM
          value: xterm
        volumeMounts:
        - name: mongodb-data
          mountPath: /data/db
  volumeClaimTemplates:
  - metadata:
      name: mongodb-data
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 1Gi
       
---
# Replica Set 3  
apiVersion: v1
kind: Service
metadata:
  name: mongors2n3
  labels:
    app: mongors2n3
spec:
  ports:
  - port: 27017
    targetPort: 27017
  selector:
    app: mongors2n3
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mongors2n3
spec:
  serviceName: "mongors2n3"
  replicas: 1
  selector:
    matchLabels:
      app: mongors2n3
  template:
    metadata:
      labels:
        app: mongors2n3
    spec:
      containers:
      - name: mongors2n3
        image: indamutsa/mongo:v1.0.0
        command:
        - mongod
        - --shardsvr
        - --replSet
        - mongors2
        - --dbpath
        - /data/db
        - --port
        - "27017"
        - --bind_ip_all
        ports:
        - containerPort: 27017
        env:
        - name: TERM
          value: xterm
        volumeMounts:
        - name: mongodb-data
          mountPath: /data/db
  volumeClaimTemplates:
  - metadata:
      name: mongodb-data
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 1Gi

EOF

echo "Kubernetes manifests written to mongodb-shard1.yaml"


#!/bin/bash

cat <<EOF > 4-mongodb-routers.yaml
# Mongos Routers replica set 1
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mongos1
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mongos1
  template:
    metadata:
      labels:
        app: mongos1
    spec:
      containers:
      - name: mongos1
        image: indamutsa/mongo:v1.0.0
        command: 
        - mongos
        - --configdb
        - mongors1conf/mongocfg1:27017,mongocfg2:27017,mongocfg3:27017
        - --port
        - "27017" 
        - --bind_ip_all
        ports:
        - containerPort: 27017
        volumeMounts:
        - name: config
          mountPath: /home/app
        resources:
          requests:
            memory: "1Gi"
            cpu: "1"
          limits:
            memory: "1Gi"
            cpu: "1"
      volumes:
      - name: config
        configMap:
          name: mongos1-config

---

apiVersion: v1
kind: Service
metadata:
  name: mongos1
spec:
  type: LoadBalancer
  ports:
  - port: 27017
    targetPort: 27017
  selector:
    app: mongos1

---

apiVersion: v1
kind: ConfigMap
metadata:
  name: mongos1-config
data:
  addShards.js: |
    sh.addShard("mongors1/mongors1n1:27017,mongors1n2:27017,mongors1n3:27017");
    sh.addShard("mongors2/mongors2n1:27017,mongors2n2:27017,mongors2n3:27017");

    // For testing the sharding
    sh.enableSharding("testDb");
    db.createCollection("kittens");
    db.kittens.createIndex({ name: "hashed" });
    sh.shardCollection("testDb.kittens", { name: "hashed" });

    // MDEForge
    sh.enableSharding("mdeforge");
    db.createCollection("artifacts");
    db.mdeforge.createIndex({ storageUrl: "hashed" });
    sh.shardCollection("mdeforge.artifacts", { storageUrl: "hashed" });

---    

# Mongos Routers replica set 2
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mongos2
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mongos2
  template:
    metadata:
      labels:
        app: mongos2
    spec:
      containers:
      - name: mongos2
        image: indamutsa/mongo:v1.0.0
        command: 
        - mongos
        - --configdb
        - mongors1conf/mongocfg1:27017,mongocfg2:27017,mongocfg3:27017
        - --port
        - "27017" 
        - --bind_ip_all
        ports:
        - containerPort: 27017
        volumeMounts:
        - name: config
          mountPath: /home/app
        resources:
          requests:
            memory: "1Gi"
            cpu: "1"
          limits:
            memory: "1Gi"
            cpu: "1"
      volumes:
      - name: config
        configMap:
          name: mongos2-config

---

apiVersion: v1
kind: Service
metadata:
  name: mongos2
spec:
  type: LoadBalancer
  ports:
  - port: 27017
    targetPort: 27017
  selector:
    app: mongos2

---

apiVersion: v1
kind: ConfigMap
metadata:
  name: mongos2-config
data:
  addShards.js: |
    sh.addShard("mongors1/mongors1n1:27017,mongors1n2:27017,mongors1n3:27017");
    sh.addShard("mongors2/mongors2n1:27017,mongors2n2:27017,mongors2n3:27017");

    // For testing the sharding
    sh.enableSharding("testDb");
    db.createCollection("kittens");
    db.kittens.createIndex({ name: "hashed" });
    sh.shardCollection("testDb.kittens", { name: "hashed" });

    // MDEForge
    sh.enableSharding("mdeforge");
    db.createCollection("artifacts");
    db.mdeforge.createIndex({ storageUrl: "hashed" });
    sh.shardCollection("mdeforge.artifacts", { storageUrl: "hashed" });

EOF

echo "Kubernetes manifests written to mongodb-routers.yaml"


#!/bin/bash

cat <<EOF > 5-setup-rs-job.yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: setup-rs
spec:
  template:
    metadata:
      labels:
        job-name: setup-rs
    spec:
      containers:
      - name: setup-rs
        image: indamutsa/setup-rs:v1.0.4
        # command:
        # - /bin/sh
        # - -c
        # - |
        #   #!/bin/sh
        #   start_time=\$(date +%s)
        #   while true; do
        #     current_time=\$(date +%s)
        #     duration=\$((current_time - start_time))
            
        #     # Exit after 180 seconds (3 minutes)
        #     if [ \$duration -ge 180 ]; then
        #       echo "Timeout reached!"
        #       exit 1
        #     fi

        #     # Check connectivity to the services
        #     if mongo mongodb://mongos1:27017/ --eval "db.adminCommand('ping')" &&
        #        mongo mongodb://mongos2:27017/ --eval "db.adminCommand('ping')" &&
        #        mongo mongodb://mongocfg1:27017/ --eval "db.adminCommand('ping')" &&
        #        mongo mongodb://mongocfg2:27017/ --eval "db.adminCommand('ping')" &&
        #        mongo mongodb://mongocfg3:27017/ --eval "db.adminCommand('ping')" &&
        #        mongo mongodb://mongors1n1:27017/ --eval "db.adminCommand('ping')" &&
        #        mongo mongodb://mongors1n2:27017/ --eval "db.adminCommand('ping')" &&
        #        mongo mongodb://mongors1n3:27017/ --eval "db.adminCommand('ping')" &&
        #        mongo mongodb://mongors2n1:27017/ --eval "db.adminCommand('ping')" &&
        #        mongo mongodb://mongors2n2:27017/ --eval "db.adminCommand('ping')" &&
        #        mongo mongodb://mongors2n3:27017/ --eval "db.adminCommand('ping')";

        #     then
        #       echo "All services are reachable!"
        #       # Place additional setup tasks here if needed
              
        #       exit 0
        #     else
        #       echo "Waiting for all services to be reachable..."
        #       sleep 10
        #     fi
        #   done
      restartPolicy: Never
EOF

echo "Job manifest written to setup-rs-job.yaml"


cat <<EOF > 1-es-master.yml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: es-master
spec:
  serviceName: es-master
  replicas: 1
  selector:
    matchLabels:
      app: es-master
  template:
    metadata:
      labels:
        app: es-master
    spec:
      containers:
      - name: es-master
        image: indamutsa/elasticsearch:v1.0.0

        env:
        - name: node.name
          value: "es-master"
        - name: node.master
          value: "true"
        - name: node.data
          value: "false"
        - name: cluster.initial_master_nodes
          value: "es-master,es-worker1,es-worker2"  # <-- Add all nodes here
        - name: ES_JAVA_OPTS
          value: "-Xmx256m -Xms256m"
        - name: ELASTICSEARCH_URL
          value: "http://es-master:9200"          
        - name: ELASTIC_USERNAME
          value: elastic
        - name: ELASTIC_PASSWORD
          value: changeme
        ports:
        - containerPort: 9200
        - containerPort: 9300
        volumeMounts:
        - name: es-master-data
          mountPath: /data/db
  volumeClaimTemplates:
  - metadata:
      name: es-master-data
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 1Gi
---
apiVersion: v1
kind: Service
metadata:
  name: es-master
spec:
  selector:
    app: es-master
  ports:
    - protocol: TCP
      port: 9200
      targetPort: 9200
      name: http-port
    - protocol: TCP
      port: 9300
      targetPort: 9300
      name: transport-port
  type: ClusterIP



EOF

echo "Created es-master deployment and service..."


cat <<EOF > 2-es-worker1.yml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: es-worker1
spec:
  serviceName: es-worker1
  replicas: 1
  selector:
    matchLabels:
      app: es-worker1
  template:
    metadata:
      labels:
        app: es-worker1
    spec:
      containers:
      - name: es-worker1
        image: indamutsa/elasticsearch:v1.0.0

        env:
        - name: node.name
          value: "es-worker1"
        - name: node.master
          value: "true"    # <-- Change this to true
        - name: node.data
          value: "true"
        - name: discovery.seed_hosts
          value: "es-master,es-worker1,es-worker2"   # <-- Add all nodes here

        - name: ES_JAVA_OPTS
          value: "-Xmx256m -Xms256m"
        - name: ELASTICSEARCH_URL
          value: "http://es-worker1:9200"          
        - name: ELASTIC_USERNAME
          value: elastic
        - name: ELASTIC_PASSWORD
          value: changeme
        ports:
        - containerPort: 9200
        - containerPort: 9300  
        volumeMounts:
        - name: es-worker1-data
          mountPath: /data/db
  volumeClaimTemplates:
  - metadata:
      name: es-worker1-data
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 1Gi
---
apiVersion: v1
kind: Service
metadata:
  name: es-worker1
spec:
  selector:
    app: es-worker1
  ports:
    - protocol: TCP
      port: 9200
      targetPort: 9200
      name: http-port
    - protocol: TCP
      port: 9300
      targetPort: 9300
      name: transport-port
  type: ClusterIP


EOF

echo "Created es-worker1 deployment and service..."


cat <<EOF > 3-es-worker2.yml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: es-worker2
spec:
  serviceName: es-worker2
  replicas: 1
  selector:
    matchLabels:
      app: es-worker2
  template:
    metadata:
      labels:
        app: es-worker2
    spec:
      containers:
      - name: es-worker2
        image: indamutsa/elasticsearch:v1.0.0

        env:
        - name: node.name
          value: "es-worker2"
        - name: node.master
          value: "true"    # <-- Change this to true
        - name: node.data
          value: "true"
        - name: discovery.seed_hosts
          value: "es-master,es-worker1,es-worker2"   # <-- Add all nodes here
        - name: node.ingest
          value: "true"
        - name: ES_JAVA_OPTS
          value: "-Xmx256m -Xms256m"
        - name: ELASTICSEARCH_URL
          value: "http://es-worker2:9200"          
        - name: ELASTIC_USERNAME
          value: elastic
        - name: ELASTIC_PASSWORD
          value: changeme
        ports:
        - containerPort: 9200
        - containerPort: 9300
        volumeMounts:
        - name: es-worker2-data
          mountPath: /data/db
  volumeClaimTemplates:
  - metadata:
      name: es-worker2-data
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 1Gi
---
apiVersion: v1
kind: Service
metadata:
  name: es-worker2
spec:
  selector:
    app: es-worker2
  ports:
    - protocol: TCP
      port: 9200
      targetPort: 9200
      name: http-port
    - protocol: TCP
      port: 9300
      targetPort: 9300
      name: transport-port
  type: ClusterIP

  
EOF

echo "Created es-worker2 deployment and service..."

cat <<EOF > 4-logstash.yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: logstash
spec:
  replicas: 1
  selector:
    matchLabels:
      app: logstash
  template:
    metadata:
      labels:
        app: logstash
    spec:
      containers:
      - name: logstash
        image: indamutsa/logstash:v1.0.0
        env:
        - name: ELASTICSEARCH_URL
          value: "http://es-master:9200"  # Adjust if needed
        ports:
        - containerPort: 5044
        - containerPort: 5000
        - containerPort: 9600
      restartPolicy: Always
---
apiVersion: v1
kind: Service
metadata:
  name: logstash
spec:
  selector:
    app: logstash
  ports:
    - name: logstash-tcp-5044
      protocol: TCP
      port: 5044
      targetPort: 5044
    - name: logstash-tcp-5000
      protocol: TCP
      port: 5000
      targetPort: 5000
    - name: logstash-tcp-9600
      protocol: TCP
      port: 9600
      targetPort: 9600
  type: ClusterIP

EOF

echo "Created logstash.sh"


cat <<EOF > 5-kibana.yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: kibana
spec:
  replicas: 1
  selector:
    matchLabels:
      app: kibana
  template:
    metadata:
      labels:
        app: kibana
    spec:
      containers:
      - name: kibana
        image: indamutsa/kibana:v1.0.0
        ports:
        - containerPort: 5601
        env:
        - name: ELASTICSEARCH_URL
          value: "http://es-master:9200"  # Adjust if needed

      restartPolicy: Always

---
apiVersion: v1
kind: Service
metadata:
  name: kibana
spec:
  selector:
    app: kibana
  ports:
    - protocol: TCP
      port: 5601
      targetPort: 5601
  type: ClusterIP


EOF

echo "Created kibana.sh"




cat <<EOF > 6-filebeat-daemonset.yml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: filebeat
spec:
  selector:
    matchLabels:
      app: filebeat
  template:
    metadata:
      labels:
        app: filebeat
    spec:
      containers:
      - name: filebeat
        image: indamutsa/filebeat:v1.0.0
        volumeMounts:
        - mountPath: /var/log
          name: system-logs
          readOnly: true
      volumes:
      - name: system-logs
        hostPath:
          path: /var/log
      terminationGracePeriodSeconds: 30

EOF

echo "Created filebeat.sh"