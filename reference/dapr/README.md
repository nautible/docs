# Dapr
リファレンスアプリケーションで利用しているDaprの機能や利用方法の注意点について記載します。

## Daprとは
DaprとはMicrosoftがGolangで作成したクラウドやエッジで実行可能なランタイムで、マイクロサービス開発を容易にする様々な機能を提供します。様々な言語や開発Frameworkと併用可能で、ポータビリティの高いアプリケーション開発を実現します。各種機能の詳細については[公式](https://dapr.io/)を参考にしてください。

## 開発Tips

### Istioと併用する場合のマニフェスト定義の注意点
- アプリケーションのマニフェストでannotationを付与することでDaprを有効化(Daprのサイドカーを有効化)する事ができます。Istioと併用する場合には以下の設定が必要です。
```
spec:
  template:
    metadata:
      ...
      annotations:
        dapr.io/enabled: "true"
        proxy.istio.io/config: '{ "holdApplicationUntilProxyStarts": true }' # https://github.com/dapr/dapr/issues/2657

```

### pub/subコンポーネントの利用の注意点
- SNS/SQSのリソースの名称を指定できない問題について  
MessageBrokerにAWSのSNS/SQSを利用した場合SNS/SQSのリソース名は指定できません。SQSはapp-idのHash値、SNSはTopic名のHash値が有効なリソース名となります。
- SNS/SQSのリソースの自動作成とPolicyについて  
SNS/SQSが事前に作成されていない場合、Daprによって自動的に作成されます。その場合は、SNS/SQSを作成するためのPolicyが必要となります。Hash値の名称で事前にリソースを作成しておけば、既存リソースを利用するので、作成するためのPolicyは必要なくなります。

## Istioとの併用について
Daprの公式見解では、Daprとサービスメッシュは併用可能であることが述べられています。フォーカスしている目的がそれぞれ異なるためです。しかし、実際にIstioとDaprを併用する場合には注意すべきポイントがあります。

### Dapr公式の見解
- [Dapr公式の見解](https://docs.dapr.io/concepts/faq/#networking-and-service-meshes)

### リファレンスアプリによる検証と注意点。
- 分散トレーシング  
  Istio、Daprはそれぞれ分散トレーシングをサポートするが独立して動作します。DaprのServiceInvocationを使った場合などは、アプリA＞DaprサイドカーA＞IstioサイドカーA＞IstioサイドカーB＞DaprサイドカーB＞アプリBのように実行されDapr、Istioそれぞれの分散トレースが有効となり基本的に違いはありません。
  一方で、Daprのpub/subを利用した場合は、Daprの分散トレースは有効になるが、Istioの分散トレースはMessagingのポーリングなどには介入できないため分散トレースなどが有効になりません。

