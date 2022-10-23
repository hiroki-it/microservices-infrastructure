{{- define "dev.customer.db.persistent-volume" }}
apiVersion: v1
kind: PersistentVolume
metadata:
  namespace: microservices
  name: customer-db-persistent-volume
  labels:
    app: customer
    component: db
    env: {{ .Values.general.env }}
    type: hostPath
spec:
  storageClassName: standard
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  hostPath:
    path: /data/src/customer
    type: DirectoryOrCreate
{{- end }}
