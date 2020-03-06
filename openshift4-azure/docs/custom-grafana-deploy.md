# Custom Grafana Deploy

The Grafana instance that comes with OpenShift Monitoring can't be modified so if you want to create some dashboards you'll need to deploy your own.

1. From the OperatorHub install Grafana into your namespace. The project tooling namespace is a good spot for this.
2. From Installed Operators, select the Grafana Operator and press Create Instance under Grafana API to create a new Grafana instance. Take note of the user/pass.
3. Grab the prometheus datasource from the built in Grafana `oc get secrets grafana-datasources -n openshift-monitoring -o yaml | grep prometheus.yaml | awk '{print $2}' | base64 -d` 
4. From Installed Operators, select the Grafana Operator and press Create Instance under Grafana Data Source API. Use the info from step 3 to fill this out. It will look like:

```
apiVersion: integreatly.org/v1alpha1
kind: GrafanaDataSource
metadata:
  name: example-grafanadatasource
  namespace: phil-grafana
spec:
  datasources:
    - basicAuthUser: internal
      access: proxy
      editable: true
      name: Prometheus
      url: 'https://prometheus-k8s.openshift-monitoring.svc:9091'
      basicAuthPassword: >-
        DZSapO22jFhlZ+oNWqZuICqg...
      jsonData:
        timeInterval: 5s
        tlsSkipVerify: true
      basicAuth: true
      isDefault: true
      version: 1
      type: prometheus
  name: example-datasources.yaml
```

You need to have some elevated rights to view the grafana secret. There is probably a better solution but this works for now :-)


## Resources 
* https://www.redhat.com/en/blog/custom-grafana-dashboards-red-hat-openshift-container-platform-4
* https://medium.com/@Awsompankaj/create-your-own-openshift-dashboard-in-grafana-ocp-3-11-f51545f3a22e