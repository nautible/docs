# Argo Workflows
リファレンスアプリケーションで利用しているArgo Workflowsの機能や利用方法の注意点について記載します。

## Argo Workflowsとは
Argo WorkflowsはKubernetesで並列ジョブをオーケストレーションするためのコンテナネイティブのワークフローエンジンで、ワークフローの各ステップがコンテナであるワークフローを実現します。各種機能の詳細については[公式](https://argoproj.github.io/argo-workflows/)を参考にしてください。

## 開発Tips

### Argo Workflows＋Daprの注意点
- Argo Workflowsで実行するアプリケーションにDaprを適用する場合に注意すべき点を本READMEで記載します。

#### ▽ Argo Workflowsで実行するアプリケーションへのDaprの適用
- PodにDaprサイドカーをインジェクションさせるためには、当該Podを制御するControllerのServiceAccountがDapr Injectorが管理するアカウントリストにリストアップされている必要があります。Kubernetes標準のController群のService Accountについてはデフォルトでリストアップされているため、特に意識することなくPodにDaprサイドカーをインジェクションさせることができます。
- 一方、Argo WorkflowsではWorkflow ControllerがPod制御を行います。そのため、Kubernetes標準ではないArgo Workflows独自のControllerが制御するPodにDaprサイドカーをインジェクションさせるためには、Dapr Injectorが管理するアカウントリストに当該アカウントを追加する必要があります。
  - Dapr Injectorが管理するアカウントリストにアカウントを追加するには、Daprの以下のHelmオプションパラメータを用います。
    ```properties
    dapr_sidecar_injector.allowedServiceAccounts=<Argo Workflows名前空間>:argo-workflows-workflow-controller
    ```

  - 詳細は、nautible-pluginにあるDaprの [appplication.yaml](https://github.com/nautible/nautible-plugin/blob/main/distributed-application/application.yaml) を参照してください。

#### ▽ Daprサイドカーのシャットダウン
- Daprのドキュメントに記載されている [Kubernetes標準のJobでDaprを実行する場合の留意点](https://docs.dapr.io/operations/hosting/kubernetes/kubernetes-job/) 同様、Argo Workflowsから実行するジョブについても同様の対処(shutdownエンドポイント呼出またはSDKでのshutdown)が必要です。
  - リファレンスアプリケーションではSDKでのshutdown処理を行っています。
    ```java
    DaprClient daprClient = ...;
    daprClient.shutdown().block();
    daprClient.close();
    ```

  - 詳細は、nautible-app-ms-stock-batchにある [CmdStockQuantityCheckService](https://github.com/nautible/nautible-app-ms-stock-batch/blob/main/nautible-app-ms-stock-batch-core/src/main/java/jp/co/ogis_ri/nautible/app/stock/batch/inbound/cmd/CmdStockQuantityCheckService.java) を参照してください。