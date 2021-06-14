# Secure deployment of MongoDB outside of Kubernetes worker nodes

As part of the Kubernetes migration project, one of our clients will migrate all of its applications to Kubernetes, however, the database services such as MongoDB (self-managed on EC2 instances) or PostgreSQL (RDS) will continue to run outside of the Kubernetes worker nodes, however, still in the same VPC.

One of the requirements of the client is to restrict access to the MongoDB and PostgreSQL databases only to the services that need it. This means that we won’t be able to allow all the pods running on our Kubernetes clusters to freely access the MongoDB instance.

How would you tackle that requirement? Which options are available to allow the clients to restrict access to the databases?

## Prerequisites

First of all, the databases should also be set up according to the principle of least privilege, so each service has its own user and this user has certain permissions.

## Solution

### Calico

Calico has network policy to limit traffic to/from external non-Calico workloads or networks.
So we can disable access from all resources to MondoDB:
```
apiVersion: projectcalico.org/v3
kind: NetworkPolicy
metadata:
  name: deny-egress-external
  namespace: default
spec:
  selector: all()
  types:
    - Egress
  egress:    
    - action: DENY
      destination:
        nets:
        - $MONGO_DB_IP/32
```
Then allow for specific applications:
```
apiVersion: projectcalico.org/v3
kind: NetworkPolicy
metadata:
  name: deny-egress-external
  namespace: default
spec:
  selector:
    service: app1
  types:
    - Egress
  egress:    
    - action: ALLOW
      destination:
        nets:
        - $MONGO_DB_IP/32
```
Also we can use `GlobalNetworkPolicy` which is not a namespaced resource.

pros: simple to set up; great flexibility.
cons: additional layer to manage.

### AWS EC2 security groups

AWS has the ability to assign specific EC2 security groups directly to pods running in Amazon EKS clusters.
There are some steps how to achieve it:
POD ENIs should be enabled:
`kubectl set env daemonset -n kube-system aws-node ENABLE_POD_ENI=true`
Create IAM policy that allows access to RDS/EC2, for example RDS action: `rds-db:connect`.
Create IAM ServiceAccount with OIDC directed to created policy from the previous step. Create SecurityGroupPolicy with serviceAccountSelector and SG IDs (they can be get via `aws eks describe-cluster --name sgp-cluster --query "cluster resourcesVpcConfig.clusterSecurityGroupId" --output text`).
After all, applications that have a ServiceAccount label that matches the filter in SecurityGroupPolicy should have access to RDS DB.

proc: no additional software needed.
cons: complicated configuration; works only on AWS EKS.


### Separate Node Group

We can spin up a separate node group for specific pods and configure its taint and affinity rules, so pods are scheduled on the node group. The node group has a Security Group attached with permissions to access MongoDB instance and RDS instance.

proc: no additional software needed.
cons: for each application with diff network policy - own node group (might be expensive).

### Istio

Install Service Mesh Istio into the cluster with `meshConfig.outboundTrafficPolicy.mode` set to
 `REGISTRY_ONLY`.
So by default, Istio blocks TCP and HTTP traffic to external hosts (outside the cluster). TCP mesh-external service resources must be created to enable traffic for TCP. 

Example for MongoDB config:

```
apiVersion: networking.istio.io/v1alpha3
kind: ServiceEntry
metadata:
  name: mongodb-external
spec:
  hosts:
  - $MONGO_DB_HOST
  addresses:
  - $MONGO_DB_IP/32
  ports:
  - name: tcp
    number: $MONGO_DB_PORT
    protocol: tcp
  location: MESH_EXTERNAL
```
Then we should use VirtualServices to control traffic bound to MongoDB external service. 

```
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: mongodb-external-rule
spec:
  hosts:
  - $MONGO_DB_HOST
  tcp:
  - match:
    - sourceLabels:
        service: app1
    route:
    - destination:
        host: $MONGO_DB_HOST

```
This means that we allow services with the label above access to the MongoDB. The same can be done for RDS instance.

pros: flexible.
cons: complicated configuration; enabling `REGISTRY_ONLY` option block all access to external services, so we need to add VirtualService for each external host is needed.


## Links

[Calico] https://docs.projectcalico.org/security/calico-network-policy

[Calico] https://docs.projectcalico.org/reference/resources/globalnetworkpolicy

[AWS EC2 security groups] https://aws.amazon.com/blogs/containers/introducing-security-groups-for-pods/

[Istio]
https://istio.io/latest/docs/reference/config/networking/service-entry/

[Istio] https://istio.io/latest/docs/tasks/traffic-management/egress/egress-control/