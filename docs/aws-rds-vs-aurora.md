# AWS RDS vs Aurora 比較ガイド

執筆日: 2025-10-15

## はじめに

AWS 上で MySQL をマネージド運用する主な選択肢は Amazon RDS for MySQL と Amazon Aurora MySQL 互換エディションです。本ドキュメントでは 2025 年時点の機能差と運用観点を整理し、どちらを採用すべきか判断するための指針をまとめます。

参考リンク:

- [Amazon Aurora Features – Amazon Web Services](https://aws.amazon.com/rds/aurora/features/)
- [Aurora vs. RDS: Difference, Performance, Cost, and Migration – Bytebase Blog](https://www.bytebase.com/blog/aurora-vs-rds/)

## アーキテクチャと可用性

- **RDS**: 単一インスタンス構成を基本とし、Multi-AZ オプションでスタンバイに同期レプリケーションを行います。フェイルオーバーは 1 分前後が目安です。
- **Aurora**: クラスタストレージを 3 AZ に 6 コピー保持し、フェイルオーバー目標は 30 秒未満。ストレージ層が独立しているためノード交換が高速です。

参考リンク:

- [Aurora 高可用性アーキテクチャ – AWS Documentation](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Concepts.AuroraHighAvailability.html)
- [Multi-AZ（シングルスタンバイ）構成 – AWS Documentation](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.MultiAZSingleStandby.html)

## パフォーマンスとスケーリング

- **RDS**: インスタンス垂直スケールと最大 5 台のリードレプリカで性能を確保します。IO 性能は選択したストレージクラスに依存します。
- **Aurora**: MySQL 比最大約 5 倍のスループットを狙える独自ストレージを採用し、最大 15 台のリードレプリカと自動ストレージ拡張 (10 GB 単位) を提供します。Serverless v2 で ACU を自動調整でき、スパイク吸収に強みがあります。

参考リンク:

- [Aurora vs. RDS: Difference, Performance, Cost, and Migration – Bytebase Blog](https://www.bytebase.com/blog/aurora-vs-rds/)
- [Amazon Aurora Features – Amazon Web Services](https://aws.amazon.com/rds/aurora/features/)

## 運用機能と互換性

- 共通: 自動バックアップ、ポイントインタイムリカバリ (PITR)、監視連携 (CloudWatch、Performance Insights) を提供。
- Aurora 固有: Backtrack による秒単位ロールバック、Data API、Global Database、Babelfish for Aurora MySQL などクラスタ拡張機能が利用可能。
- RDS 固有: MySQL 以外のエンジンも同一 UI / API で統合管理でき、Outposts などハイブリッド構成での導入が容易。

参考リンク:

- [Amazon Aurora Features – Amazon Web Services](https://aws.amazon.com/rds/aurora/features/)
- [Amazon Aurora vs. Amazon RDS: Comparison Guide – ManageEngine Applications Manager](https://www.manageengine.com/products/applications_manager/tech-topics/amazon-aurora-vs-rds-comparison-guide.html)

## コストとバージョン管理

- **RDS**: 小規模ワークロードではインスタンス料金＋ストレージ＋ I/O の組み合わせで低コストに収まるケースが多く、Free Tier やリザーブドインスタンスも利用可能。2024 年以降は旧バージョン維持に Extended Support 料金が発生する点に注意。
- **Aurora**: ACU (またはプロビジョンド容量) とストレージに基づく従量課金。高負荷時に単位コストが下がる設計で、I/O-Optimized や Serverless 予約で予測性を高められますが、最小構成でも RDS より高額になる場合があります。

参考リンク:

- [Aurora vs. RDS: Difference, Performance, Cost, and Migration – Bytebase Blog](https://www.bytebase.com/blog/aurora-vs-rds/)
- [Amazon Aurora Features – Amazon Web Services](https://aws.amazon.com/rds/aurora/features/)

## 推奨シナリオ

- **RDS を選ぶ**: 既存 MySQL を最小変更でリフト＆シフトしたい。複数エンジンを一元管理したい。一定負荷の小規模環境でコスト最適化を優先したい。
- **Aurora を選ぶ**: 読み込みレプリカを大量に抱える高トラフィック環境。Serverless で秒単位の需要変動に追従したい。Backtrack や Global Database など Aurora 固有機能が要件に合致する。

参考リンク:

- [Aurora vs. RDS: Difference, Performance, Cost, and Migration – Bytebase Blog](https://www.bytebase.com/blog/aurora-vs-rds/)
- [Amazon Aurora Features – Amazon Web Services](https://aws.amazon.com/rds/aurora/features/)

## 移行と検証のヒント

- DMS や標準レプリケーションを使って段階移行が可能。Aurora は RDS スナップショットのインポートや binlog レプリケーション、Babelfish を活用した異種移行に対応。
- Aurora MySQL は InnoDB を前提とするため、MyISAM など非対応ストレージエンジンは事前に変換が必要です。
- フェイルオーバー時間やパフォーマンス特性は環境依存なので、事前にベンチマークと障害訓練を実施し、README や運用 Runbook に結果を反映してください。

参考リンク:

- [Amazon Aurora Overview – AWS Documentation](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Aurora.Overview.html)
- [Multi-AZ DB クラスタの概要 – AWS Documentation](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/multi-az-db-clusters-concepts.html)
- [Aurora 高可用性アーキテクチャ – AWS Documentation](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Concepts.AuroraHighAvailability.html)

## Q & A

### Q: そもそもクラスタとは何を指しますか？

A: 複数の DB ノードを単一の論理データベースとして扱い、共通ストレージやエンドポイントを通じて高可用性とスケーラビリティを実現する構成です。Aurora は共有ストレージを 3 AZ × 6 コピーで保持し、フェイルオーバー時もデータコピーを作り直す必要がないクラウドネイティブ設計です。

参考リンク:

- [Amazon Aurora Overview – AWS Documentation](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Aurora.Overview.html)
- [Aurora 高可用性アーキテクチャ – AWS Documentation](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Concepts.AuroraHighAvailability.html)

### Q: RDS には Aurora のようなクラスタ機能がありますか？

A: あります。MySQL/PostgreSQL 向けに Multi-AZ DB クラスタが提供され、1 ライターと 2 リーダーを 3 つのアベイラビリティゾーンに配置します。セミ同期レプリケーションで書き込みを保護しつつ、リーダーエンドポイント経由で読み込み分散とフェイルオーバー（目標 35 秒未満）が可能です。

参考リンク:

- [Multi-AZ DB クラスタの概要 – AWS Documentation](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/multi-az-db-clusters-concepts.html)
- [Multi-AZ DB クラスタの接続管理 – AWS Documentation](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/multi-az-db-clusters-concepts-connection-management.html)

### Q: RDS Multi-AZ DB クラスタは 1 writer / 1 reader の構成にできますか？

A: いいえ。Multi-AZ DB クラスタは常に 1 ライター＋2 リーダーの 3 台構成が最小です。台数を絞りたい場合は従来型の Multi-AZ DB インスタンス（ライター＋スタンバイ）を検討してください。

参考リンク:

- [Multi-AZ DB クラスタの概要 – AWS Documentation](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/multi-az-db-clusters-concepts.html)
- [Multi-AZ（シングルスタンバイ）構成 – AWS Documentation](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.MultiAZSingleStandby.html)

### Q: スタンバイとリードレプリカの違いは？

A: スタンバイは同期レプリケーションでフェイルオーバー専用に待機し、通常時は読み取り不可です。リードレプリカは非同期で更新を複製し、読み取り負荷分散や分析用途に利用でき、必要に応じて昇格も可能です。

参考リンク:

- [Multi-AZ（シングルスタンバイ）構成 – AWS Documentation](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.MultiAZSingleStandby.html)
- [Read Replicas for Amazon RDS – AWS Documentation](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_ReadRepl.html)

### Q: RDS の冗長化パターンはスタンバイ構成とクラスタ構成の 2 種類と考えてよいですか？

A: 概ねその捉え方で問題ありません。冗長化しない Single-AZ 構成に加え、同期スタンバイを備える「Multi-AZ DB インスタンス」と、1 ライター＋2 リーダーを持つ「Multi-AZ DB クラスタ」が提供されています。後者は平常時もリーダーで読み取り分散でき、Aurora に近い操作感です。

参考リンク:

- [Amazon RDS Multi-AZ Deployments – AWS Features](https://aws.amazon.com/rds/features/multi-az/)
- [Amazon RDS Multi-AZ DB Cluster – AWS Blog](https://aws.amazon.com/blogs/aws/amazon-rds-multi-az-db-cluster/)

### Q: RDS の代表的な構成モードは何がありますか？

A: 大きく 3 つに分類できます。

- **Single-AZ DB インスタンス**
  - 追加コストや自動フェイルオーバーのない単一インスタンス構成。Multi-AZ を有効化しない場合はこのモードになります。
- **Multi-AZ DB インスタンス（従来型スタンバイ構成）**
  - プライマリと同期レプリケーションされたスタンバイ 1 台を別 AZ に配置し、障害時のみスタンバイが昇格します（通常時は読み取り不可）。
- **Multi-AZ DB クラスタ（1 writer + 2 readable standbys）**
  - 3 つの AZ にライター 1 台とリーダー 2 台を配置し、平常時からリーダーで読み取り分散が可能です。フェイルオーバー目標も短縮されています。

どの構成でも必要に応じて非同期のリードレプリカを追加し、読み込みスケールアウトを強化できます。

参考リンク:

- [Amazon RDS Multi-AZ Deployments – AWS Features](https://aws.amazon.com/rds/features/multi-az/)
- [Amazon RDS Multi-AZ DB Cluster – AWS Blog](https://aws.amazon.com/blogs/aws/amazon-rds-multi-az-db-cluster/)
- [Read Replicas for Amazon RDS – AWS Documentation](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_ReadRepl.html)

### Q: Single-AZ DB インスタンスでもリードレプリカを 1 台追加して運用できますか？

A: できます。Single-AZ のプライマリから非同期レプリケーションによるリードレプリカを作成でき、読み取り負荷のオフロードや緊急時の手動昇格に利用できます。ただしプライマリ側には自動フェイルオーバーが無いため、高可用性要件がある場合は Multi-AZ への切り替えも検討してください。

参考リンク:

- [Read Replicas for Amazon RDS – AWS Documentation](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_ReadRepl.html)
