# HypervCsi Helm chart

Helm chart for **HypervCsi**, a Kubernetes CSI driver for Microsoft Hyper-V. Volumes are VHDX files on
Hyper-V hosts or cluster shared volumes, managed over PowerShell remoting.

The chart installs:

- the `CSIDriver` object `eu.nova.csi.hyperv` (`attachRequired: true`, `fsGroupPolicy: File`);
- the controller Deployment with the provisioner, attacher, resizer and health-monitor sidecars;
- the node DaemonSet with the node-driver-registrar;
- optionally the WinMgmtFramework WebApi (`global.winmgmtframeworkwebapi.enabled`), which talks to the
  Hyper-V hosts. It usually runs outside the cluster; the CSI components reach it at
  `CsiDriverOptions__ApiUrl`.

## Images

The images are private:

```
ghcr.io/baremetal-works/novahypervcsi/csicontroller
ghcr.io/baremetal-works/novahypervcsi/csinode
ghcr.io/baremetal-works/novahypervcsi/winmgmframeworkapi
```

Create a pull secret with the token you were given (scope `read:packages`):

```bash
kubectl create namespace csi-hyperv
kubectl -n csi-hyperv create secret docker-registry ghcr-regcred \
  --docker-server=ghcr.io --docker-username=<user> --docker-password=<token>
```

## Install

```bash
git clone https://github.com/baremetal-works/hypervcsi-helm.git
helm install hypervcsi ./hypervcsi-helm/charts/hypervcsi -n csi-hyperv -f my-values.yaml
```

Values to set (see `charts/hypervcsi/values.yaml`):

| Value | Meaning |
|---|---|
| `global.imageTag` | Image tag for all three images, e.g. `v1.1.3` |
| `global.imagePullSecrets` | Pull secret for ghcr.io (default `ghcr-regcred`) |
| `CsiDriverOptions__ApiUrl` (controller and node `environment`) | URL of the WinMgmtFramework WebApi |
| `CsiDriverOptions__ApiToken` (controller and node `environment`) | API key of the WebApi |
| `global.license.existingSecret` | Secret holding the signed license file (`license.lic`) |

## License

The driver needs a license file for production use. Create the Secret and point the chart at it:

```bash
kubectl -n csi-hyperv create secret generic hypervcsi-license --from-file=license.lic=./license.lic
helm upgrade hypervcsi ./hypervcsi-helm/charts/hypervcsi -n csi-hyperv --reuse-values \
  --set global.license.existingSecret=hypervcsi-license
```
