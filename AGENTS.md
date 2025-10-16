# Repository Guidelines

## プロジェクト構成とモジュール配置

- `docker-compose.yml` は PostgreSQL 18.0 と MySQL 8.4.6 の 2 サービスを起動し、永続ボリュームと `TZ=Asia/Tokyo` を共通設定としています。
- `initdb/postgresql` と `initdb/mysql` には `NNN_description.sql` 形式の初期化スクリプトを配置し、権限ロールと接続ユーザーを定義します。番号は実行順序なので、新規追加時はゼロ埋め 3 桁で連番を増やしてください。
- `Makefile` には Docker Compose をラップした運用コマンドがまとまり、開発用接続も同一インターフェースで扱えます。
- `README.md` で各データベースの確認手順を更新するため、構成変更ごとにコマンド例を同期してください。

## ビルド・テスト・開発コマンド

- `make upd-psql` / `make down-psql` / `make downv-psql` … PostgreSQL サービスの起動・停止。`downv` はボリューム削除で初期化スクリプトを再実行します。
- `make conn-psql` … `app_dev_user` で `psql` に接続します。初期化内容の検証に `\du`、`\drg` を併用してください。
- `make upd-mysql` / `make down-mysql` / `make downv-mysql` … MySQL サービス用。`downv` で `/docker-entrypoint-initdb.d` を再適用します。
- `make conn-mysql` … `app_dev_user` で `mysql` に接続し、`show grants` でロール状態を確認します。
- 共通の後片付けは `make down` で停止＋ボリューム解放、`docker compose` を直接実行する際も `Makefile` を参照して引数を揃えてください。

## コーディングスタイルと命名規則

- SQL スクリプトは大文字キーワード＋小文字スネークケースのロール名、2 スペースインデントで揃えます。
- コメントは `--` でセクションを明示し、目的・実行者・注意点を短く書き添えます。既存ファイルのヘッダーテンプレートを再利用してください。
- 新しいユーザーやロールを追加するときは PostgreSQL / MySQL 双方の整合性を保ち、差異が必要な場合はコメントで理由を説明します。

## ドキュメント作成ガイド

- Mermaid 図で改行が必要な場合は `\n` ではなく `<br />` を使用してください（GitHub Flavored Markdown では `\n` が効かないため）。

## テストガイドライン

- 自動テストは未整備のため、コンテナ起動後に REPL で権限確認を行います。PostgreSQL では `make conn-psql` ののち `\du`、`\drg`、MySQL では `make conn-mysql` ののち `\s`、`show grants for app_dev_user;` を実行してください。
- 新しいスキーマや権限を追加した場合は、SQL スクリプト適用後に `\dn`、`\dt` 等でオブジェクト所有者を確認し、README の検証例を更新します。
- 将来的な自動化に備え、検証で使ったコマンドや結果を Pull Request に貼り付けて再現性を残します。

## コミットとプルリクエスト

- コミットメッセージは `chore: ...` や `docs: ...` のように Conventional Commits に沿って種別を明示します。SQL の追加は `feat:`、設定調整は `chore:` を推奨します。
- 1 コミットにつき 1 論点を守り、`docker-compose.yml` と `initdb` の変更は関連するものを同じコミットにまとめてください。
- プルリクエストでは目的、主な変更点、使用した検証コマンド、影響範囲を箇条書きで記載し、Issue があればリンクします。環境構築に影響する変更ではスクリーンショットの代わりに REPL ログを添付するとレビューが容易です。

## セキュリティと構成メモ

- 初期化スクリプト内のパスワードは開発用の固定値です。本番相当の接続情報は `docker-compose.yml` や `.envrc` に直書きせず、別途環境変数やシークレットストアで管理してください。
- すべてのコンテナは `TZ=Asia/Tokyo` を前提としているため、他タイムゾーンで検証する場合は影響範囲を README に追記してください。
- ボリュームを削除するとデータが失われるため、分析用途で保持したいデータは `docker volume inspect` で場所を確認しバックアップを取ってから `make downv-*` を実行します。
