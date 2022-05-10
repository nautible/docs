# リファレンスアプリケーションの概要とアーキテクチャ

---
## 1. コンテキスト
### 1.1 アプリケーションの概要
- [アプリケーションの概要](./1_context/app-common/README.md)

---
## 2. 機能
### 2.1 アプリケーションの機能
- [アプリケーションの機能](./2_function/README.md)

---
## 3. 情報
### 3.1 データの永続化とトランザクション
- [リファレンスアプリケーションにおけるトランザクション管理](./3_information/persistence-and-transaction/transaction/README.md)

---
## 4. 並行性
### 4.1 サービス間の通信
- [リファレンスアプリケーションにおけるサービス間通信](./4_concurrency/service-communication/service-communication/README.md)
- [重複リクエストの排除](./4_concurrency/service-communication/exclusion-duplicate-requests/README.md)

---
## 5. 開発
### 5.1 各サービスの標準化
- [実装ルール](./5_development/services-standardization/impl-rule.md "実装ルール")
- [構成管理ルール](./5_development/services-standardization/scm-rule.md "構成管理ルール")
- [ローカル環境での開発方法](./5_development/services-standardization/local-develop.md "ローカル環境での開発方法")
- [Telepresence](./5_development/services-standardization/telepresence/README.md "Telepresence")
- [nautible-frontend](https://github.com/nautible/nautible-front/blob/main/README.md "nautible-frontend")

### 5.2 テスト

---
## 6. 配置
### 6.1 CI/CD
- [CI/CD](https://github.com/nautible/nautible-infra/blob/main/ci_cd/README.md "CI/CD")

---
## 7. 運用
### 7.1 サービスの運用
- [動作確認用テストデータ](https://github.com/nautible/nautible-app-ms-order/blob/main/testdata.md
 "動作確認用テストデータ")
- [Istio](https://github.com/nautible/nautible-plugin/blob/main/service-mesh/README.md)
- [監視系（モニタリング/ロギング/トレーシング）](https://github.com/nautible/nautible-plugin/blob/main/observation/README.md "監視系（モニタリング/ロギング/トレーシング）")
- 計画停止・起動
  - [EKS](https://github.com/nautible/nautible-infra/blob/main/aws/terraform/nautible-aws-platform/modules/tool/eks-planned-outage/README.md)
  - [AKS](https://github.com/nautible/nautible-infra/blob/main/azure/terraform/nautible-azure-platform/modules/tool/aks-planned-outage/README.md)
### 7.2 共通サービス