apiVersion: apps/v1
kind: Deployment
metadata:
  name: prometheus-deployment-staging
  namespace: laa-apply-for-criminal-legal-aid-staging
spec:
  replicas: 1
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 50%
      maxSurge: 100%
  selector:
    matchLabels:
      app: apply-for-criminal-legal-aid-prometheus-staging
  template:
    metadata:
      labels:
        app: apply-for-criminal-legal-aid-prometheus-staging
        tier: worker
    spec:
      containers:
      - name: prometheus-exporter
        image: ${ECR_URL}:${IMAGE_TAG}
        imagePullPolicy: Always
        command: ["/bin/sh", "-c", "bundle exec prometheus_exporter -b 0.0.0.0 --verbose"]
        ports:
          - containerPort: 9394
        resources:
          requests:
            cpu: 25m
            memory: 1Gi
          limits:
            cpu: 500m
            memory: 3Gi
        readinessProbe:
          httpGet:
            path: /ping
            port: 9394
          initialDelaySeconds: 10
          periodSeconds: 60
        livenessProbe:
          httpGet:
            path: /ping
            port: 9394
          initialDelaySeconds: 15
          periodSeconds: 60
