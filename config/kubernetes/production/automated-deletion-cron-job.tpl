apiVersion: batch/v1
kind: CronJob
metadata:
  name: automated-deletion-cron-job-production
  namespace: laa-apply-for-criminal-legal-aid-production
spec:
  schedule: "0 0 * * *" # daily at midnight
  concurrencyPolicy: Forbid
  jobTemplate:
    spec:
      template:
        metadata:
          labels:
            tier: worker
        spec:
          timeZone: "Europe/London"
          restartPolicy: OnFailure
          containers:
          - name: automated-deletion-job
            image: ${ECR_URL}:${IMAGE_TAG}
            imagePullPolicy: Always
            command:
              - bin/rails
              - automated_deletion
            resources:
              limits:
                cpu: 50m
                memory: 1Gi
            envFrom:
              - configMapRef:
                  name: configmap-production
              - secretRef:
                  name: laa-apply-for-criminal-legal-aid-secrets
            env:
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
