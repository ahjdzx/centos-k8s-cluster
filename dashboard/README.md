## To deploy Dashboard, execute following command:

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-rc3/aio/deploy/recommended.yaml
```

## Create An Authentication Token (RBAC)

### Creating sample user

#### Create Service Account

```bash
kubectl apply -f dashboard-adminuser.yaml
```

#### Create ClusterRoleBinding

```bash
kubectl apply -f dashboard-clusterrolebinding.yaml
```

#### Bearer Token

```bash
kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')
```