// database/sql を使って「書き込みはマスター」「読み取りはリードレプリカ」に振り分けるサンプルコード
// アプリケーション起動時に 2 本の接続を用意し、Repository 内で用途ごとにハンドルを切り替える。

package data

import (
	"context"
	"database/sql"
	"fmt"
	"time"
)

type DBPair struct {
	Write *sql.DB
	Read  *sql.DB
}

func NewDBPair(masterDSN, replicaDSN string) (*DBPair, error) {
	writeDB, err := sql.Open("mysql", masterDSN)
	if err != nil {
			return nil, fmt.Errorf("open master: %w", err)
	}
	readDB, err := sql.Open("mysql", replicaDSN)
	if err != nil {
			writeDB.Close()
		return nil, fmt.Errorf("open replica: %w", err)
	}
	// コネクションプール設定の一例
	for _, db := range []*sql.DB{writeDB, readDB} {
			db.SetMaxOpenConns(20)
			db.SetMaxIdleConns(5)
			db.SetConnMaxLifetime(30 * time.Minute)
	}
	return &DBPair{Write: writeDB, Read: readDB}, nil
}

type UserRepository struct {
	db *DBPair
}

func NewUserRepository(db *DBPair) *UserRepository {
	return &UserRepository{db: db}
}

// 書き込み系はマスター（Write）を使用
func (r *UserRepository) CreateUser(ctx context.Context, name string) error {
	_, err := r.db.Write.ExecContext(ctx, `INSERT INTO users(name) VALUES(?)`, name)
	return err
}

// 読み取り系はリードレプリカ（Read）を使用
func (r *UserRepository) FindUser(ctx context.Context, id int64) (string, error) {
	var name string
	err := r.db.Read.QueryRowContext(ctx, `SELECT name FROM users WHERE id = ?`, id).Scan(&name)
	return name, err
}

// アプリ側では NewDBPair にマスターとレプリカの DSN（user:pass@tcp(host:port)/dbname など）を
// 渡し、UserRepository を DI するだけで読み書き分離ができる。
// トランザクションが必要な処理は db.Write.BeginTx(ctx, nil) の結果を使って実行し、
// 読み込みトラフィックを複数台に広げたい場合は DBPair.Read を
// ロードバランサ配下のエンドポイントや接続先リストでラップすると発展させられる。
