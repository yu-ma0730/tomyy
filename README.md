# Gold Regularity Signal Tool

ゴール（GOLD/金）の15分足チャートにおけるEMA規則性パターンを自動検出するトレーディング信号ツール。

**対応プラットフォーム**: TradingView（PineScript）/ MT5（MQL5）

---

## 📊 機能概要

このツールは、以下の3つの規則性ルールに基づいてシグナルを生成します：

### ✅ Rule #1: EMAパーフェクトオーダー
価格とEMA（10, 20, 40, 80）が整列したトレンド方向を検出

### ✅ Rule #2: EMAブレークダウン検出
EMA下抜けから次のEMAへの下落を予測する**ショートシグナル**

### ✅ Rule #3: EMA20バウンス検出  
EMA20での複数反発パターンを特定

---

## 🚀 クイックスタート

### TradingView での使用

1. **PineScript をコピー**
   ```
   /tradingview/GoldRuleSignalTool.pine
   ```

2. **インジケーター追加**
   - TradingView チャートを開く
   - `新規スクリプト` → PineScript v5
   - スクリプトをコピーペースト
   - チャートに追加

3. **設定**
   - インジケーター設定でアラート有効化
   - 色をカスタマイズ（オプション）

### MT5 での使用

1. **MQL5スクリプトをコピー**
   ```
   /mt5/GoldRuleSignalTool.mq5
   ```

2. **MetaEditor で開く**
   - MT5 → ツール → MetaEditor
   - スクリプトを開く/新規作成

3. **コンパイル**
   - `F5` キーでコンパイル
   - エラーがないか確認

4. **チャートに追加**
   - MT5 チャートを開く（GOLD, 15分足）
   - インジケーター/スクリプトを追加
   - パラメータを設定

---

## 🎯 シグナルの見方

### 矢印マーク
- **🔴 下向き矢印**: ショートシグナル（EMA10/20ブレークダウン）
- **🟢 上向き矢印**: ロングシグナル（EMA20バウンス）

### 色分けゾーン
- **オレンジ色**: EMA20 アラートゾーン
- **青色**: EMA80 最終反発ゾーン
- **灰色**: 通常バリア

### 情報テーブル（TradingView）
- **Rule #1**: Perfect Order の状態
- **Rule #2**: EMA ブレークの状態  
- **Rule #3**: EMA20 バウンスの状態
- トレンド方向の確認

---

## ⚙️ 設定オプション

### アラート設定
```
- Enable Alerts: アラート音/メッセージの有効化
- Enable Notifications: プッシュ通知の有効化
```

### 表示設定
```
- UP Signal Color: 上昇シグナルの矢印色
- DOWN Signal Color: 下降シグナルの矢印色
- Signal Arrow Size: 矢印のサイズ
- EMA Alert Zone Color: アラートゾーンの色
```

---

## 📈 トレーディングルール

### ショート（SHORT）エントリー
```
1. EMA10 下抜けを確認
   ↓
2. 一時的な反発を待つ（騙し対策）
   ↓
3. 再度下落開始を確認
   ↓
4. エントリー実行
   ↓
5. 目標: EMA20 / EMA40 / EMA80
```

### ロング（LONG）エントリー
```
1. EMA20 バウンスまたは最終反発（EMA80）を待つ
   ↓
2. 反発開始を確認
   ↓
3. エントリー実行
   ↓
4. 目標: 1つ上のEMA または 上昇トレンド継続
```

### 重要な注意
- ⚠️ **絶対ルール**: EMA下抜け直後のエントリーは避ける
- ⚠️ **騙しパターン**: EMA20での複数反発で含み損が長くなる場合あり
- ⚠️ **メンタル管理**: ロット調整とロスカット水準をあらかじめ決定

---

## 📊 精度と統計

- **精度**: 約70～80%程度（統計ベース）
- **確実性**: 100%ではありません
- **相場適応**: 相場環境によって有効性が変わる可能性あり

---

## 📚 詳細ドキュメント

詳細なルール解説、エントリータイミング、リスク管理については：

👉 **[GOLD_REGULARITY_RULES.md](./docs/GOLD_REGULARITY_RULES.md)**

---

## 🔧 開発者向け情報

### ファイル構成
```
/
├── mt5/
│   └── GoldRuleSignalTool.mq5      # MT5用スクリプト
├── tradingview/
│   └── GoldRuleSignalTool.pine     # TradingView用スクリプト
├── docs/
│   └── GOLD_REGULARITY_RULES.md    # 詳細ドキュメント
└── README.md                        # このファイル
```

### カスタマイズ方法

#### TradingView でのカスタマイズ
1. スクリプトを編集モードで開く
2. 入力パラメータを変更
   ```javascript
   enableAlerts = input.bool(true, "Enable Alerts", group="Alerts")
   signalSize = input.int(2, "Signal Arrow Size", group="Display")
   ```

#### MT5 でのカスタマイズ  
1. MetaEditor でスクリプトを開く
2. パラメータを変更
   ```mql5
   input bool EnableAlerts = true;
   input bool EnableNotifications = false;
   input int SignalSize = 2;
   ```

---

## ⚠️ 免責事項

このツールは教育目的で提供されています。

- 投資判断は自己責任で行ってください
- 過去の統計に基づいていますが、将来の値動きを保証しません
- 実装により生じたいかなる損失についても責任は負いません
- デモトレードから始めることを推奨します

---

## 🔄 バージョン情報

**v1.0** - 2024年
- 3つの規則性ルール実装完了
- TradingView / MT5 両プラットフォーム対応
- アラート・通知機能対応

---

## 📞 サポート・フィードバック

バグ報告や機能改善のご提案は、GitHub Issues をご利用ください。

---

**最後に**: このツールの検証や改善のため、必ず過去チャートで検証してからご使用ください。

Happy Trading! 📊
