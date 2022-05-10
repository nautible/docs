# Quarkus
リファレンスアプリケーションで利用しているQuarkusの機能や利用方法の注意点について記載します。  


## Quarkusとは
QuarkusとはKubernetesネイティブなJavaのフレームワークです。MicroProfile互換のマイクロサービスブレンドリーなフレームワークで、アプリケーションの高速な起動やメモリ削減を目的にNativeビルドやFast-JARビルドをサポートしています。各種機能の詳細については[公式](https://quarkus.io/)を参考にしてください。  

## サービスの実装
### コードの自動生成について
- gRPC  
  quarkus-maven-pluginで[proto3](https://developers.google.com/protocol-buffers/docs/proto3)の定義からIFを自動生成しています。

- REST  
  openapi-generator-maven-pluginで[Open API specification](https://github.com/OAI/OpenAPI-Specification)の定義からIFを自動生成しています。

### 入力値チェック
- REST  
  Quarkusの[公式参照](https://quarkus.io/guides/validation)。

- gRPC  
  gRPCの入力値チェックの方法については色々な方式がありますが、protoから生成するコードを手動編集しない、また、ServerInterceptorとHibernateValidatorを活用する方式について記載します。HibernateValidatorの詳細については[公式参照](https://docs.jboss.org/hibernate/validator/7.0/reference/en-US/html_single/)。

ValidationInterceptor
```
@ApplicationScoped
public class ValidationInterceptor implements ServerInterceptor {

  Validator validator;

  @PostConstruct
  public void postConstruct() {
    // https://github.com/quarkusio/quarkus/issues/5531
    // Quarkus管理のValidatorはxmlのvalidation定義を有効にならないため独自のインスタンスを利用する
    ValidatorFactory factory = Validation.buildDefaultValidatorFactory();
    validator = factory.getValidator();
  }

  @Override
  public <I, O> ServerCall.Listener<I> interceptCall(ServerCall<I, O> call, final Metadata requestHeaders,
      ServerCallHandler<I, O> next) {
    ServerCall.Listener<I> listeners = next.startCall(call, requestHeaders);
    return new SimpleForwardingServerCallListener<I>(listeners) {
      @Override
      public void onMessage(I message) {
        // リクエストメッセージのValidationを実行
        Set<ConstraintViolation<I>> violations = validator.validate(message);
        if (!violations.isEmpty()) {
          Status status = Status.INVALID_ARGUMENT
              .withDescription(new ConstraintViolationException(violations).getMessage());
          call.close(status, requestHeaders);
        } else {
          super.onMessage(message);
        }
      }

    };

  }

}

```

  [ポイント]
  - protoから自動生成したIFを最大限活用するため、生成後のIFを手動修正しないため、xmlによるValidation定義を行います。
  - QuarkusのValidation機能はバグにより[xmlのValidation定義が有効にならない](https://github.com/quarkusio/quarkus/issues/5531)。そのため、validatorのインスタンスは独自に生成する必要があるます。また、Quarkusが提供するValidation関連機能や定義方法は利用できません。
  - アノテーションによるValidation定義やQuarkusのValidation関連機能を有効活用したい場合は、この方式は利用せず自動生成後のIFを編集するなどの方式を検討が必要です。

## 開発TIPS 
### 環境毎のログフォーマット切替

- ログの出力フォーマット
本番環境などでは各種ツールにてログの解析が行いやすいようにjsonフォーマットでログ出力します。ローカル開発環境では可読性の良いテキストフォーマットで出力するようにします。環境毎の設定変更はQuarkusのプロファイルを利用しています。詳細は[ドキュメント参照](https://quarkus.io/guides/logging#json-logging)。

pom.xml
```
 <dependencies>
    <dependency>
      <groupId>io.quarkus</groupId>
      <artifactId>quarkus-logging-json</artifactId>
    </dependency>
  </dependencies>
```

application.properties
```
local-dev.quarkus.log.console.json=false
```

### Skaffoldを利用したローカルのデバッグ方法について

- DeploymentマニュフェストのContainerの環境変数を追加することでデバッグが有効となります。詳細については[公式ドキュメント](https://skaffold.dev/docs/workflows/debug/)参照。
```
~省略~
  containers:
  - name: nautible-app-ms-customer
    env:
　　　~省略~
    - name: JAVA_VERSION
      value: "11"
```
- デバッグオプションを指定してSkaffoldを実行します。以下の例では5005ポートがデバッグポートとして公開されています。
```
>skaffold dev --port-forward
Listing files to watch...
~省略~
Press Ctrl+C to exit
Forwarding container nautible-app-ms-customer-ff499f84c-r4vhp/nautible-app-ms-customer to local port 8081.
Not watching for changes...
Port forwarding service/nautible-app-ms-customer in namespace nautible-app-ms, remote port 8080 -> address 127.0.0.1 port 8080
Port forwarding pod/nautible-app-ms-customer-ff499f84c-r4vhp in namespace nautible-app-ms, remote port 8080 -> address 127.0.0.1 port 8081
Forwarding container nautible-app-ms-customer-ff499f84c-r4vhp/nautible-app-ms-customer to local port 9003.
Port forwarding service/nautible-app-ms-customer in namespace nautible-app-ms, remote port 9000 -> address 127.0.0.1 port 9002
Port forwarding pod/nautible-app-ms-customer-ff499f84c-r4vhp in namespace nautible-app-ms, remote port 9000 -> address 127.0.0.1 port 9003
Port forwarding pod/nautible-app-ms-customer-ff499f84c-r4vhp in namespace nautible-app-ms, remote port 5005 -> address 127.0.0.1 port 5005
```

### 監視
- Prometailのメトリクス定義
  prometheusのアラートルールでエラーログ検知を行うためのメトリクス定義を行っています。Quarkusが依存するライブラリによってはエラーレベル「SEVERE」でエラーログを出力するのでメトリクスを２つ定義する必要があります（valueには複数の値や正規表現が定義できない）。

nautible-infra\ArgoCD\apps\observation\promtail\application.yaml
```
            - metrics:
                log_error_total:
                  type: Counter
                  description: error number
                  prefix: customer_
                  source: level
                  config:
                    value: ERROR
                    action: inc
                log_severe_total:
                  type: Counter
                  description: error number
                  prefix: customer_
                  source: level
                  config:
                    value: SEVERE
                    action: inc

```
