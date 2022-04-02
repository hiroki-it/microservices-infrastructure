{{- define "dev.order.db.stateful-set" }}
apiVersion: apps/v1
kind:  StatefulSet
metadata:
  namespace: microservices
  name: order-db-pod
  labels:
    app: order
    component: db
    env: {{ .Values.labels.env }}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: order
      component: db
      env: {{ .Values.labels.env }}
  serviceName: order-app-service
  template:
    metadata:
      labels:
        app: order
        component: db
        env: {{ .Values.labels.env }}
    spec:
      containers:
        # MySQLコンテナ（開発環境のみ）
        - name: mysql
          image: mysql:5.7
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 3306
          env:
            - name: MYSQL_ROOT_PASSWORD
              value: root
            - name: MYSQL_DATABASE
              value: dev_db
            - name: MYSQL_USER
              value: dev_user
            - name: MYSQL_PASSWORD
              value: dev_password
          volumeMounts:
            - name: order-db-host-path-persistent-volume-claim
              # NOTE:
              # mysqld: Can't create/write to file '/var/lib/mysql/is_writable' (Errcode: 13 - Permission denied)
              # datadirにマウントできない．
              mountPath: /var/volume
  volumeClaimTemplates:
    - metadata:
        name: order-db-host-path-persistent-volume-claim
        labels:
          app: order
          component: db
          env: {{ .Values.labels.env }}
      spec:
        storageClassName: standard
        accessModes:
          - ReadWriteOnce
        resources:
          requests:
            storage: 5Gi
        selector:
          matchLabels:
            component: db
            env: {{ .Values.labels.env }}
            type: hostPath
{{- end }}
