---
description: "組立工程表と曲げ工程表の調査"
argument_hint: "調査内容を引数で入力"
---
私は組立工程表作成機能(S010101)と曲げ工程表作成機能(S010102)の修正をしています。
組立工程表作成機能と曲げ工程表作成機能はtakeuchi-kouzai.order-management-appがフロントエンド、order-management-reports-appがバックエンドの役割をしています。
takeuchi-kouzai.order-management-appとorder-management-reports-appはWinformで作成されたアプリケーションをマイグレーションしたものです。
２つのアプリケーションはSQL Serverをデータベースとして用いています。
ローカル実行用のデータベースは以下の接続情報で接続できます。
ホスト:localhost
データベース名:Takeuchi_DB
ユーザー:sa
パスワード:sa
2つの機能はビューを多用しているので、定義の確認が必要な場合はsqlcmdコマンドでデータベースに接続して確認してください。
組立工程表作成機能のマイグレーション前のソースコードは@S010101.csにあります。
曲げ工程表作成機能のマイグレーション前のソースコードは@S010102.csにあります。
$1
