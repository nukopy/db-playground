# Terraform on AWS メモ

執筆日: 2025-10-15

## 開発環境の RDS へセキュアに接続する一般的な方法

- RDS はプライベートサブネットに配置し、VPC セキュリティグループでアクセス元 CIDR とポートを最小化します。マルチ AZ を考慮した DB サブネットグループを用意することでフェイルオーバー時も非公開のまま利用できます。
- 踏み台が必要な場合は AWS Systems Manager Session Manager や EC2 Instance Connect Endpoint を組み合わせ、ポートを公開しないバスティオン構成を採用します。
- 社内ネットワークからのアクセスは AWS Site-to-Site VPN や AWS Direct Connect 経由でプライベート接続を確保し、RDS を公開せずに運用します。
- データパスは TLS/SSL を強制し、IAM データベース認証や RDS Proxy の IAM 連携でパスワードレス接続を構成します。
- 接続情報は AWS Secrets Manager に保管し、自動ローテーションを有効化して長期共有パスワードを廃止します。

参考リンク:

- [Working with a DB instance in a VPC](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_VPC.WorkingWithRDSInstanceinaVPC.html)
- [Security best practices for Amazon RDS for MySQL and MariaDB instances](https://aws.amazon.com/blogs/database/security-best-practices-for-amazon-rds-for-mysql-and-mariadb-instances/)
- [Controlling access with security groups](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Overview.RDSSecurityGroups.html)
- [Access a bastion host by using Session Manager and EC2 Instance Connect](https://docs.aws.amazon.com/prescriptive-guidance/latest/patterns/access-a-bastion-host-by-using-session-manager-and-amazon-ec2-instance-connect.html)
- [Securely connect to an Amazon RDS instance remotely with Session Manager](https://aws.amazon.com/blogs/database/securely-connect-to-an-amazon-rds-or-amazon-ec2-database-instance-remotely-with-your-preferred-gui/)
- [Internetwork traffic privacy for Amazon RDS](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/inter-network-traffic-privacy.html)
- [Amazon RDS Proxy announces support for end-to-end IAM authentication](https://aws.amazon.com/about-aws/whats-new/2025/09/amazon-rds-proxy-end-to-end-iam-authentication/)
- [Connecting to a database through RDS Proxy](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/rds-proxy-connecting.html)
- [Password management with Amazon RDS and AWS Secrets Manager](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/rds-secrets-manager.html)
- [AWS Secrets Manager best practices](https://docs.aws.amazon.com/secretsmanager/latest/userguide/best-practices.html)

## RDS インスタンスのみ構築するときに必要な AWS リソース

- **VPC & サブネット**: 2 つ以上の AZ にプライベートサブネットを用意し、DB サブネットグループへ関連付けます。
- **セキュリティグループ**: データベース用に専用グループを作成し、踏み台やアプリ層など必要な送信元のみ許可します。
- **DB サブネットグループ**: Terraform では `aws_db_subnet_group` を定義し、プライベートサブネットを紐付けます。
- **DB パラメーターグループ**: 既定値を変更する場合はカスタムグループを作成し、テスト環境で検証した上で適用します。
- **シークレット管理**: `aws_secretsmanager_secret` で資格情報を格納し、Terraform からは参照のみにします。
- **任意リソース**: 追加機能が必要なら Option Group を、詳細メトリクスが必要なら Enhanced Monitoring 用 IAM ロールと設定を作成します。

参考リンク:

- [Working with a DB instance in a VPC](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_VPC.WorkingWithRDSInstanceinaVPC.html)
- [Controlling access with security groups](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Overview.RDSSecurityGroups.html)
- [Overview of parameter groups](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/parameter-groups-overview.html)
- [Password management with Amazon RDS and AWS Secrets Manager](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/rds-secrets-manager.html)
- [Working with option groups](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_WorkingWithOptionGroups.html)
- [Setting up and enabling Enhanced Monitoring](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_Monitoring.OS.Enabling.html)

## Terraform ディレクトリ構成とコード配置

- ルートは `main.tf / variables.tf / outputs.tf / providers.tf / versions.tf` など役割ごとにファイルを分け、`envs/<environment>/terraform.tfvars` で環境値を管理します。
- 再利用可能な構成は `modules/` に切り出し、README と例を添えてルートから `source = "./modules/..."` で参照します。
- チーム規模が拡大する場合は live コードと再利用モジュールをリポジトリ内で分離し、CI/CD で環境差分を検知できるようにします。
- アプリケーションコードと Terraform を同居させる場合でもディレクトリとバックエンド設定を分離し、レビュー単位を明確にします。

参考リンク:

- [Best practices for code base structure and organization (Terraform on AWS)](https://docs.aws.amazon.com/prescriptive-guidance/latest/terraform-aws-provider-best-practices/structure.html)
- [Terraform infrastructure-as-code best practices](https://dev.to/devopsdaily/terraform-infrastructure-as-code-best-practices-doe)
- [Best practices for general style and structure (Terraform)](https://cloud.google.com/docs/terraform/best-practices/general-style-structure)
