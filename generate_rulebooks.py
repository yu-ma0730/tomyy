#!/usr/bin/env python3
# -*- coding: utf-8 -*-
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import cm
from reportlab.lib import colors
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, PageBreak, Table, TableStyle
from reportlab.pdfgen import canvas
from reportlab.lib.utils import ImageReader
import io

def create_p4_pdf():
    """P4手法PDFを生成"""
    filename = "P4手法.pdf"
    doc = SimpleDocTemplate(filename, pagesize=A4, topMargin=1.5*cm, bottomMargin=1.5*cm)

    styles = getSampleStyleSheet()
    story = []

    # カスタムスタイル
    title_style = ParagraphStyle(
        'CustomTitle',
        parent=styles['Heading1'],
        fontSize=24,
        textColor=colors.HexColor('#0066cc'),
        spaceAfter=6,
        alignment=1  # center
    )

    subtitle_style = ParagraphStyle(
        'CustomSubtitle',
        parent=styles['Normal'],
        fontSize=12,
        textColor=colors.HexColor('#666666'),
        spaceAfter=20,
        alignment=1  # center
    )

    heading_style = ParagraphStyle(
        'CustomHeading',
        parent=styles['Heading2'],
        fontSize=14,
        textColor=colors.black,
        spaceAfter=10,
        spaceBefore=10
    )

    body_style = ParagraphStyle(
        'CustomBody',
        parent=styles['Normal'],
        fontSize=11,
        textColor=colors.black,
        spaceAfter=10,
        leading=16
    )

    # タイトル
    story.append(Paragraph("P4 手法", title_style))
    story.append(Paragraph("Pull back & Position Strategy", subtitle_style))
    story.append(Spacer(1, 0.5*cm))

    # ステップ1
    story.append(Paragraph("【ステップ1】トレンド確認", heading_style))
    story.append(Paragraph(
        "• 強いアップトレンドを確認<br/>"
        "• 高値が更新されている状態<br/>"
        "• 移動平均線上にある",
        body_style
    ))
    story.append(Spacer(1, 0.3*cm))

    # ステップ2
    story.append(Paragraph("【ステップ2】プルバック待機", heading_style))
    story.append(Paragraph(
        "• 価格が一時的に戻す<br/>"
        "• サポートレベルで反発<br/>"
        "• 焦らず待つことが大切",
        body_style
    ))
    story.append(Spacer(1, 0.3*cm))

    # ステップ3
    story.append(Paragraph("【ステップ3】ポジション構築", heading_style))
    story.append(Paragraph(
        "• プルバック後の反発を確認<br/>"
        "• サポート＋αで買い<br/>"
        "• 複数回に分けてエントリー",
        body_style
    ))
    story.append(Spacer(1, 0.3*cm))

    # ストップロス
    story.append(Paragraph("【ストップロス配置】", heading_style))
    story.append(Paragraph(
        "• サポートレベル下に設定<br/>"
        "• ロット数に合わせて計算<br/>"
        "• 必ず事前に設定すること",
        body_style
    ))
    story.append(Spacer(1, 0.5*cm))

    # ポイント
    story.append(Paragraph("💡 P4のコツ", heading_style))
    story.append(Paragraph(
        "急いでエントリーしないこと。プルバックが完了し、再度上昇トレンドが始まったことを確認してからポジションを構築します。タイムフレームはH1以上推奨。",
        body_style
    ))

    doc.build(story)
    print(f"✅ {filename} を生成しました")

def create_zigzag_pdf():
    """ジグザグ手法PDFを生成"""
    filename = "ジグザグ手法.pdf"
    doc = SimpleDocTemplate(filename, pagesize=A4, topMargin=1.5*cm, bottomMargin=1.5*cm)

    styles = getSampleStyleSheet()
    story = []

    # カスタムスタイル
    title_style = ParagraphStyle(
        'CustomTitle',
        parent=styles['Heading1'],
        fontSize=24,
        textColor=colors.HexColor('#9c27b0'),
        spaceAfter=6,
        alignment=1  # center
    )

    subtitle_style = ParagraphStyle(
        'CustomSubtitle',
        parent=styles['Normal'],
        fontSize=12,
        textColor=colors.HexColor('#666666'),
        spaceAfter=20,
        alignment=1  # center
    )

    heading_style = ParagraphStyle(
        'CustomHeading',
        parent=styles['Heading2'],
        fontSize=14,
        textColor=colors.black,
        spaceAfter=10,
        spaceBefore=10
    )

    body_style = ParagraphStyle(
        'CustomBody',
        parent=styles['Normal'],
        fontSize=11,
        textColor=colors.black,
        spaceAfter=10,
        leading=16
    )

    # タイトル
    story.append(Paragraph("ジグザグ手法", title_style))
    story.append(Paragraph("Zigzag Pattern Trend Following", subtitle_style))
    story.append(Spacer(1, 0.5*cm))

    # パターン認識
    story.append(Paragraph("【パターン認識】", heading_style))
    story.append(Paragraph(
        "• 安値の切り上げ：L1 &lt; L2 &lt; L3<br/>"
        "• 高値の更新：H1 &lt; H2 &lt; H3<br/>"
        "• または高値の切り下げ：H1 &gt; H2 &gt; H3 (下降時)",
        body_style
    ))
    story.append(Spacer(1, 0.3*cm))

    # トレード実行
    story.append(Paragraph("【トレード実行】", heading_style))
    story.append(Paragraph(
        "• アップ時：前の高値H2を抜ける<br/>"
        "• ダウン時：前の安値L2を抜ける<br/>"
        "• 確認：トレンドの継続を確認",
        body_style
    ))
    story.append(Spacer(1, 0.3*cm))

    # エントリールール
    story.append(Paragraph("【エントリールール】", heading_style))
    story.append(Paragraph(
        "• 直前の高値/安値ブレイクで<br/>"
        "• ボリューム確認を必須<br/>"
        "• 複数ジグザグで信頼性UP<br/>"
        "• 時間軸の統一を推奨",
        body_style
    ))
    story.append(Spacer(1, 0.3*cm))

    # ストップロス
    story.append(Paragraph("【ストップロス】", heading_style))
    story.append(Paragraph(
        "• アップ時：L3の下に設定<br/>"
        "• ダウン時：H3の上に設定<br/>"
        "• 余裕を持った設定が重要<br/>"
        "• ロット計算で調整する",
        body_style
    ))
    story.append(Spacer(1, 0.5*cm))

    # ポイント
    story.append(Paragraph("💡 ジグザグのポイント", heading_style))
    story.append(Paragraph(
        "このパターンはトレンド継続の確認に使います。3つ以上のポイント（3山3谷）で信頼性が高まります。ゴールドやFXペアで24時間、高い流動性があるため効果的です。",
        body_style
    ))

    doc.build(story)
    print(f"✅ {filename} を生成しました")

def create_risk_pdf():
    """リスク管理PDFを生成"""
    filename = "リスク管理.pdf"
    doc = SimpleDocTemplate(filename, pagesize=A4, topMargin=1.5*cm, bottomMargin=1.5*cm)

    styles = getSampleStyleSheet()
    story = []

    # カスタムスタイル
    title_style = ParagraphStyle(
        'CustomTitle',
        parent=styles['Heading1'],
        fontSize=24,
        textColor=colors.HexColor('#d32f2f'),
        spaceAfter=6,
        alignment=1  # center
    )

    subtitle_style = ParagraphStyle(
        'CustomSubtitle',
        parent=styles['Normal'],
        fontSize=12,
        textColor=colors.HexColor('#666666'),
        spaceAfter=20,
        alignment=1  # center
    )

    heading_style = ParagraphStyle(
        'CustomHeading',
        parent=styles['Heading2'],
        fontSize=14,
        textColor=colors.black,
        spaceAfter=10,
        spaceBefore=10
    )

    body_style = ParagraphStyle(
        'CustomBody',
        parent=styles['Normal'],
        fontSize=11,
        textColor=colors.black,
        spaceAfter=10,
        leading=16
    )

    # タイトル
    story.append(Paragraph("⚠️ リスク管理（最優先）", title_style))
    story.append(Paragraph("Risk Management is Everything", subtitle_style))
    story.append(Spacer(1, 0.5*cm))

    # 絶対ルール
    story.append(Paragraph("【絶対ルール】", heading_style))
    story.append(Paragraph(
        "1. 1トレードで失ってもいい金額は口座残高の1-2%まで<br/>"
        "2. エントリー前にストップロスを決める（後付け厳禁）<br/>"
        "3. テイクプロフィットを最初に計算する（欲張り厳禁）<br/>"
        "4. 連敗中は取引をやめる（感情的判断の防止）",
        body_style
    ))
    story.append(Spacer(1, 0.3*cm))

    # ロット計算フロー
    story.append(Paragraph("【ロット計算フロー】", heading_style))

    data = [
        ['ステップ', '計算式', '例'],
        ['Step 1', '口座残高 × 1%', '1000$ × 1% = 10$'],
        ['Step 2', 'SLまでのpips', 'SL 50 pips'],
        ['Step 3', 'ロット数 = リスク額 ÷ (SL×対象ペア)', '10$ ÷ 50pips = 0.02'],
        ['Step 4', '最終確認', '0.02 × 50pips = 10$'],
    ]

    t = Table(data, colWidths=[2*cm, 6*cm, 4*cm])
    t.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), colors.lightgrey),
        ('TEXTCOLOR', (0, 0), (-1, 0), colors.black),
        ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
        ('FONTNAME', (0, 0), (-1, 0), 'Courier'),
        ('FONTSIZE', (0, 0), (-1, 0), 11),
        ('BOTTOMPADDING', (0, 0), (-1, 0), 12),
        ('BACKGROUND', (0, 1), (-1, -1), colors.white),
        ('TEXTCOLOR', (0, 1), (-1, -1), colors.black),
        ('FONTSIZE', (0, 1), (-1, -1), 10),
        ('GRID', (0, 0), (-1, -1), 1, colors.black),
    ]))
    story.append(t)
    story.append(Spacer(1, 0.3*cm))

    # 連敗時の対応
    story.append(Paragraph("【連敗時の対応】", heading_style))

    loss_data = [
        ['連敗数', '対応', '説明'],
        ['1-2連敗', '通常継続', 'ルール確認'],
        ['3連敗', 'ロット50%減', '一呼吸入れる'],
        ['5連敗', 'ロット10%', 'マイルール再学習'],
        ['7連敗以上', '取引中止', '24時間休場'],
    ]

    t2 = Table(loss_data, colWidths=[2*cm, 3*cm, 5*cm])
    t2.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), colors.lightgrey),
        ('TEXTCOLOR', (0, 0), (-1, 0), colors.black),
        ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
        ('FONTNAME', (0, 0), (-1, 0), 'Courier'),
        ('FONTSIZE', (0, 0), (-1, 0), 11),
        ('BOTTOMPADDING', (0, 0), (-1, 0), 12),
        ('BACKGROUND', (0, 1), (-1, -1), colors.white),
        ('TEXTCOLOR', (0, 1), (-1, -1), colors.black),
        ('FONTSIZE', (0, 1), (-1, -1), 10),
        ('GRID', (0, 0), (-1, -1), 1, colors.black),
    ]))
    story.append(t2)
    story.append(Spacer(1, 0.3*cm))

    # トレード日誌
    story.append(Paragraph("【トレード日誌をつける】", heading_style))
    story.append(Paragraph(
        "• エントリー理由<br/>"
        "• エントリー価格と時刻<br/>"
        "• ストップロスとテイクプロフィット<br/>"
        "• 結果（損益、理由の正確性）<br/>"
        "• 改善点",
        body_style
    ))

    doc.build(story)
    print(f"✅ {filename} を生成しました")

if __name__ == '__main__':
    create_p4_pdf()
    create_zigzag_pdf()
    create_risk_pdf()
    print("\n✅ すべてのPDFを生成しました！")
