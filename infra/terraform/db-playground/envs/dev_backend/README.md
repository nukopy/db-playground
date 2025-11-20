# dev backend bootstrap

このディレクトリでは Terraform のリモートステート (S3 + DynamoDB ロック) をブートストラップするためのコードを配置してください。

例:
- `main.tf` で S3 バケット (`aws_s3_bucket`) と DynamoDB テーブル (`aws_dynamodb_table`) を作成
- 環境固有のタグやバケット名 (`db-playground-terraform-dev` など) を変数化

`infra/envs/dev/backend.tf` で使用するバケット/テーブル名と整合するようにしてください。
