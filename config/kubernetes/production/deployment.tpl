apiVersion: apps/v1
kind: Deployment
metadata:
  name: deployment-production
  namespace: laa-apply-for-criminal-legal-aid-production
spec:
  replicas: 4
  revisionHistoryLimit: 5
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 50%
      maxSurge: 100%
  selector:
    matchLabels:
      app: apply-for-criminal-legal-aid-web-production
  template:
    metadata:
      labels:
        app: apply-for-criminal-legal-aid-web-production
        tier: frontend
    spec:
      containers:
      - name: webapp
        image: ${ECR_URL}:${IMAGE_TAG}
        imagePullPolicy: Always
        ports:
          - containerPort: 3000
        resources:
          requests:
            cpu: 25m
            memory: 1Gi
          limits:
            cpu: 500m
            memory: 3Gi
        readinessProbe:
          httpGet:
            path: /health
            port: 3000
            httpHeaders:
              - name: X-Forwarded-Proto
                value: https
              - name: X-Forwarded-Ssl
                value: "on"
          initialDelaySeconds: 15
          periodSeconds: 10
        livenessProbe:
          httpGet:
            path: /health
            port: 3000
            httpHeaders:
              - name: X-Forwarded-Proto
                value: https
              - name: X-Forwarded-Ssl
                value: "on"
          initialDelaySeconds: 30
          periodSeconds: 10
        envFrom:
          - configMapRef:
              name: configmap-production
          - secretRef:
              name: secrets-production
        env:
          #
          # secrets created by `certificates.yml`
          #
          - name: LAA_PORTAL_SP_CERT
            valueFrom:
              secretKeyRef:
                name: portal-sp-certificate-production
                key: tls.crt
          - name: LAA_PORTAL_SP_PRIVATE_KEY
            valueFrom:
              secretKeyRef:
                name: portal-sp-certificate-production
                key: tls.key
          #
          # secrets created by `terraform`
          #
          - name: DATABASE_URL
            valueFrom:
              secretKeyRef:
                name: rds-instance
                key: url
          - name: DATASTORE_API_AUTH_SECRET
            valueFrom:
              secretKeyRef:
                name: datastore-api-auth-secret
                key: secret
