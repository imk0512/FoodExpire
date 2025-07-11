# FoodExpire

OCR を使って食品の賞味期限を管理する SwiftUI アプリです。
メイン画面では写真を撮影するかライブラリから選択して食品を登録できます。
テキスト認識によって自動で食品名と期限が入力され、保存前に編集することもできます。

アプリは日本語と英語のローカライズに対応しています。

## 主な機能
- ML Kit OCR を利用した写真の撮影・選択とテキスト認識
- 賞味期限付きで食品を Firestore に保存
- 賞味期限順に並んだ登録済みアイテムの一覧表示
- 期限が近づいたら通知を送信
- 詳細画面から過去に保存した食品を再登録
- バナー広告を削除するオプションのアプリ内課金
- 期限が近い食品から簡単なレシピを提案

## セットアップ
1. Xcode 15 以降で `Package.swift` を開きます
2. Firebase 設定ファイル `GoogleService-Info.plist` を `Sources/FoodExpire/Resources/` 配下に追加します
3. `FoodExpire` スキームを選択し、iOS 17 シミュレータまたはデバイスで実行します

Firebase の依存ライブラリは Swift Package Manager で解決されます。Firestore とテキスト認識用 ML Kit が含まれています。
