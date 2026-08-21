#!/usr/bin/env python3
# -*- coding: utf-8 -*-
from weasyprint import HTML, CSS
from io import StringIO

def create_p4_html_pdf():
    """P4手法のHTMLをPDFに変換"""
    html_content = """
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8">
        <style>
            body {
                font-family: 'Arial', 'Segoe UI', sans-serif;
                margin: 0;
                padding: 40px;
                background: white;
                color: #000;
            }
            h1 {
                font-size: 32px;
                margin: 0 0 10px 0;
                color: #0066cc;
                font-weight: 700;
            }
            .subtitle {
                margin: 0 0 30px 0;
                color: #666;
                font-size: 14px;
            }
            .section {
                margin-bottom: 30px;
            }
            h2 {
                font-size: 18px;
                margin: 0 0 15px 0;
                color: #000;
                font-weight: 700;
                padding: 10px;
                background: #f5f5f5;
                border-left: 4px solid #0066cc;
            }
            p, li {
                font-size: 13px;
                line-height: 1.8;
                color: #000;
            }
            ul {
                margin: 10px 0;
                padding-left: 30px;
            }
            li {
                margin-bottom: 8px;
            }
            .tip {
                background: #fef3c7;
                border-left: 4px solid #fbbf24;
                padding: 15px;
                margin: 20px 0;
                font-size: 13px;
            }
        </style>
    </head>
    <body>
        <h1>P4 手法</h1>
        <p class="subtitle">Pull back & Position Strategy</p>

        <div class="section">
            <h2>【ステップ1】トレンド確認</h2>
            <ul>
                <li>強いアップトレンドを確認</li>
                <li>高値が更新されている状態</li>
                <li>移動平均線上にある</li>
            </ul>
        </div>

        <div class="section">
            <h2>【ステップ2】プルバック待機</h2>
            <ul>
                <li>価格が一時的に戻す</li>
                <li>サポートレベルで反発</li>
                <li>焦らず待つことが大切</li>
            </ul>
        </div>

        <div class="section">
            <h2>【ステップ3】ポジション構築</h2>
            <ul>
                <li>プルバック後の反発を確認</li>
                <li>サポート＋αで買い</li>
                <li>複数回に分けてエントリー</li>
            </ul>
        </div>

        <div class="section">
            <h2>【ストップロス配置】</h2>
            <ul>
                <li>サポートレベル下に設定</li>
                <li>ロット数に合わせて計算</li>
                <li>必ず事前に設定すること</li>
            </ul>
        </div>

        <div class="tip">
            <strong>💡 P4のコツ：</strong> 急いでエントリーしないこと。プルバックが完了し、再度上昇トレンドが始まったことを確認してからポジションを構築します。タイムフレームはH1以上推奨。
        </div>
    </body>
    </html>
    """

    HTML(string=html_content).write_pdf("P4手法.pdf")
    print("✅ P4手法.pdf を生成しました")

def create_zigzag_html_pdf():
    """ジグザグ手法のHTMLをPDFに変換"""
    html_content = """
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8">
        <style>
            body {
                font-family: 'Arial', 'Segoe UI', sans-serif;
                margin: 0;
                padding: 40px;
                background: white;
                color: #000;
            }
            h1 {
                font-size: 32px;
                margin: 0 0 10px 0;
                color: #9c27b0;
                font-weight: 700;
            }
            .subtitle {
                margin: 0 0 30px 0;
                color: #666;
                font-size: 14px;
            }
            .section {
                margin-bottom: 30px;
            }
            h2 {
                font-size: 18px;
                margin: 0 0 15px 0;
                color: #000;
                font-weight: 700;
                padding: 10px;
                background: #f5f5f5;
                border-left: 4px solid #9c27b0;
            }
            p, li {
                font-size: 13px;
                line-height: 1.8;
                color: #000;
            }
            ul {
                margin: 10px 0;
                padding-left: 30px;
            }
            li {
                margin-bottom: 8px;
            }
            .tip {
                background: #e1f5fe;
                border-left: 4px solid #0277bd;
                padding: 15px;
                margin: 20px 0;
                font-size: 13px;
            }
        </style>
    </head>
    <body>
        <h1>ジグザグ手法</h1>
        <p class="subtitle">Zigzag Pattern Trend Following</p>

        <div class="section">
            <h2>【パターン認識】</h2>
            <ul>
                <li><strong>安値の切り上げ</strong><br/>L1 &lt; L2 &lt; L3</li>
                <li><strong>高値の更新</strong><br/>H1 &lt; H2 &lt; H3</li>
                <li><strong>または高値の切り下げ</strong><br/>H1 &gt; H2 &gt; H3 (下降時)</li>
            </ul>
        </div>

        <div class="section">
            <h2>【トレード実行】</h2>
            <ul>
                <li><strong>アップ時：</strong>前の高値H2を抜ける</li>
                <li><strong>ダウン時：</strong>前の安値L2を抜ける</li>
                <li><strong>確認：</strong>トレンドの継続を確認</li>
            </ul>
        </div>

        <div class="section">
            <h2>【エントリールール】</h2>
            <ul>
                <li>直前の高値/安値ブレイクで</li>
                <li>ボリューム確認を必須</li>
                <li>複数ジグザグで信頼性UP</li>
                <li>時間軸の統一を推奨</li>
            </ul>
        </div>

        <div class="section">
            <h2>【ストップロス】</h2>
            <ul>
                <li><strong>アップ時：</strong>L3の下に設定</li>
                <li><strong>ダウン時：</strong>H3の上に設定</li>
                <li>余裕を持った設定が重要</li>
                <li>ロット計算で調整する</li>
            </ul>
        </div>

        <div class="tip">
            <strong>💡 ジグザグのポイント：</strong> このパターンはトレンド継続の確認に使います。3つ以上のポイント（3山3谷）で信頼性が高まります。ゴールドやFXペアで24時間、高い流動性があるため効果的です。
        </div>
    </body>
    </html>
    """

    HTML(string=html_content).write_pdf("ジグザグ手法.pdf")
    print("✅ ジグザグ手法.pdf を生成しました")

def create_risk_html_pdf():
    """リスク管理のHTMLをPDFに変換"""
    html_content = """
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8">
        <style>
            body {
                font-family: 'Arial', 'Segoe UI', sans-serif;
                margin: 0;
                padding: 40px;
                background: white;
                color: #000;
            }
            h1 {
                font-size: 32px;
                margin: 0 0 10px 0;
                color: #d32f2f;
                font-weight: 700;
            }
            .subtitle {
                margin: 0 0 30px 0;
                color: #666;
                font-size: 14px;
            }
            .section {
                margin-bottom: 30px;
            }
            h2 {
                font-size: 18px;
                margin: 0 0 15px 0;
                color: #000;
                font-weight: 700;
                padding: 10px;
                background: #f5f5f5;
                border-left: 4px solid #d32f2f;
            }
            p, li {
                font-size: 13px;
                line-height: 1.8;
                color: #000;
            }
            ul {
                margin: 10px 0;
                padding-left: 30px;
            }
            li {
                margin-bottom: 8px;
            }
            table {
                width: 100%;
                border-collapse: collapse;
                margin: 15px 0;
                font-size: 12px;
            }
            table th {
                background: #f0f0f0;
                color: #000;
                padding: 10px;
                text-align: left;
                border: 1px solid #ccc;
                font-weight: 700;
            }
            table td {
                padding: 10px;
                border: 1px solid #ccc;
                color: #000;
                background: white;
            }
            .tip {
                background: #ffebee;
                border-left: 4px solid #d32f2f;
                padding: 15px;
                margin: 20px 0;
                font-size: 13px;
            }
        </style>
    </head>
    <body>
        <h1>⚠️ リスク管理（最優先）</h1>
        <p class="subtitle">Risk Management is Everything</p>

        <div class="section">
            <h2>【絶対ルール】</h2>
            <ul>
                <li><strong>1. 1トレードで失ってもいい金額は口座残高の1-2%まで</strong></li>
                <li><strong>2. エントリー前にストップロスを決める（後付け厳禁）</strong></li>
                <li><strong>3. テイクプロフィットを最初に計算する（欲張り厳禁）</strong></li>
                <li><strong>4. 連敗中は取引をやめる（感情的判断の防止）</strong></li>
            </ul>
        </div>

        <div class="section">
            <h2>【ロット計算フロー】</h2>
            <table>
                <tr>
                    <th>ステップ</th>
                    <th>計算式</th>
                    <th>例</th>
                </tr>
                <tr>
                    <td>Step 1</td>
                    <td>口座残高 × 1%</td>
                    <td>1000$ × 1% = 10$</td>
                </tr>
                <tr>
                    <td>Step 2</td>
                    <td>SLまでのpips</td>
                    <td>SL 50 pips</td>
                </tr>
                <tr>
                    <td>Step 3</td>
                    <td>ロット数 = リスク額 ÷ (SL×対象ペア)</td>
                    <td>10$ ÷ 50pips = 0.02</td>
                </tr>
                <tr>
                    <td>Step 4</td>
                    <td>最終確認</td>
                    <td>0.02 × 50pips = 10$</td>
                </tr>
            </table>
        </div>

        <div class="section">
            <h2>【連敗時の対応】</h2>
            <table>
                <tr>
                    <th>連敗数</th>
                    <th>対応</th>
                    <th>説明</th>
                </tr>
                <tr>
                    <td>1-2連敗</td>
                    <td>通常継続</td>
                    <td>ルール確認</td>
                </tr>
                <tr>
                    <td>3連敗</td>
                    <td>ロット50%減</td>
                    <td>一呼吸入れる</td>
                </tr>
                <tr>
                    <td>5連敗</td>
                    <td>ロット10%</td>
                    <td>マイルール再学習</td>
                </tr>
                <tr>
                    <td>7連敗以上</td>
                    <td>取引中止</td>
                    <td>24時間休場</td>
                </tr>
            </table>
        </div>

        <div class="section">
            <h2>【トレード日誌をつける】</h2>
            <ul>
                <li>エントリー理由</li>
                <li>エントリー価格と時刻</li>
                <li>ストップロスとテイクプロフィット</li>
                <li>結果（損益、理由の正確性）</li>
                <li>改善点</li>
            </ul>
        </div>

        <div class="tip">
            <strong>📋 最重要：</strong> リスク管理がすべてです。感情的にならず、ルールに従って機械的に取引してください。
        </div>
    </body>
    </html>
    """

    HTML(string=html_content).write_pdf("リスク管理.pdf")
    print("✅ リスク管理.pdf を生成しました")

if __name__ == '__main__':
    create_p4_html_pdf()
    create_zigzag_html_pdf()
    create_risk_html_pdf()
    print("\n✅ すべてのPDFを生成しました！")
