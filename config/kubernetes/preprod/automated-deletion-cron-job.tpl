apiVersion: batch/v1
kind: CronJob
metadata:
  name: automated-deletion-cron-job-preprod
  namespace: laa-apply-for-criminal-legal-aid-preprod
spec:
  schedule: "0 12 * * *" # daily at 12 PM
  concurrencyPolicy: Forbid
  jobTemplate:
    spec:
      template:
        metadata:
          labels:
            tier: worker
        spec:
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
                  name: configmap-preprod
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
