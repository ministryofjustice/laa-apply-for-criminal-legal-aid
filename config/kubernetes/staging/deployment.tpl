apiVersion: apps/v1
kind: Deployment
metadata:
  name: deployment-staging
  namespace: laa-apply-for-criminal-legal-aid-staging
spec:
  replicas: 2
  revisionHistoryLimit: 5
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 50%
      maxSurge: 100%
  selector:
    matchLabels:
      app: apply-for-criminal-legal-aid-web-staging
  template:
    metadata:
      labels:
        app: apply-for-criminal-legal-aid-web-staging
        tier: frontend
    spec:
      containers:
      - name: webapp
        image: ${ECR_URL}:${IMAGE_TAG}
        imagePullPolicy: Always
        ports:
          - containerPort: 9292
        resources:
          requests:
            cpu: 125m
            memory: 500Mi
          limits:
            cpu: 250m
            memory: 1Gi
        readinessProbe:
          httpGet:
            path: /
            port: 9292
            httpHeaders:
              - name: X-Forwarded-Proto
                value: https
              - name: X-Forwarded-Ssl
                value: "on"
          initialDelaySeconds: 5
          periodSeconds: 10
        livenessProbe:
          httpGet:
            path: /
            port: 9292
            httpHeaders:
              - name: X-Forwarded-Proto
                value: https
              - name: X-Forwarded-Ssl
                value: "on"
          initialDelaySeconds: 15
          periodSeconds: 10
        envFrom:
          - configMapRef:
              name: configmap-staging
