// Chart Pattern Data
const patterns = [
    {
        id: 'head-shoulders',
        name: 'ヘッドアンドショルダーズ',
        type: 'reversal',
        badge: 'high',
        description: '左肩、頭、右肩の3つの山を形成する反転パターン。最も有名で信頼度の高いパターンです。アップトレンドの終わりを示唆し、ネックラインを下抜けでシグナルが確定します。',
        keyPoints: [
            '左肩、頭、右肩がほぼ同じレベルの谷（ネックライン）を共有',
            '頭が最も高く、両肩はほぼ同じ高さ',
            'ネックラインをはっきり下抜けがシグナル',
            '下落目標は頭の高さ - ネックラインの高さ分'
        ],
        data: [
            {open: 100, close: 95, high: 105, low: 90},
            {open: 95, close: 110, high: 115, low: 92},
            {open: 110, close: 105, high: 120, low: 100},
            {open: 105, close: 125, high: 130, low: 102},
            {open: 125, close: 115, high: 135, low: 110},
            {open: 115, close: 95, high: 118, low: 92},
            {open: 95, close: 110, high: 115, low: 90},
            {open: 110, close: 100, high: 112, low: 95},
            {open: 100, close: 85, high: 105, low: 80},
            {open: 85, close: 75, high: 90, low: 70}
        ]
    },
    {
        id: 'double-top',
        name: 'ダブルトップ',
        type: 'reversal',
        badge: 'high',
        description: 'ほぼ同じ高さの2つの山が谷を挟んで形成されるシンプルなパターン。買い圧力が弱まり、売り側が市場を支配し始める兆候。谷（ネックライン）を下抜けで売りシグナル。',
        keyPoints: [
            '2つの山がほぼ同じ高さ（±1%程度）',
            '山と山の間の谷が明確',
            'ネックラインのブレイクで確定',
            'シンプルな形だが信頼度が高い'
        ],
        data: [
            {open: 100, close: 95, high: 105, low: 90},
            {open: 95, close: 105, high: 110, low: 92},
            {open: 105, close: 110, high: 115, low: 100},
            {open: 110, close: 100, high: 112, low: 95},
            {open: 100, close: 110, high: 115, low: 98},
            {open: 110, close: 105, high: 116, low: 102},
            {open: 105, close: 95, high: 108, low: 90},
            {open: 95, close: 85, high: 98, low: 80},
            {open: 85, close: 75, high: 88, low: 70}
        ]
    },
    {
        id: 'triple-top',
        name: 'トリプルトップ',
        type: 'reversal',
        badge: 'medium',
        description: '3度の試験を示す3つの同じ高さの山。買い勢力が何度も上値を試しますが、その度に反発される形。最終的にネックラインを下抜けると強い売りシグナル。',
        keyPoints: [
            '3つの山がほぼ同じ高さ',
            '形成に時間がかかる（数週間以上）',
            '3度目の試験失敗が重要',
            '下落目標は山の高さの2倍程度'
        ],
        data: [
            {open: 100, close: 102, high: 110, low: 98},
            {open: 102, close: 108, high: 112, low: 100},
            {open: 108, close: 105, high: 110, low: 103},
            {open: 105, close: 98, high: 107, low: 95},
            {open: 98, close: 107, high: 112, low: 96},
            {open: 107, close: 104, high: 110, low: 102},
            {open: 104, close: 98, high: 106, low: 95},
            {open: 98, close: 105, high: 110, low: 96},
            {open: 105, close: 102, high: 108, low: 100},
            {open: 102, close: 85, high: 105, low: 80}
        ]
    },
    {
        id: 'double-bottom',
        name: 'ダブルボトム',
        type: 'reversal',
        badge: 'high',
        description: 'ほぼ同じ深さの2つの谷が山を挟んで形成される反転パターン。下落の終わりを示唆し、買い勢力が市場を支配し始めます。ネックラインを上抜けで買いシグナル。',
        keyPoints: [
            '2つの谷がほぼ同じ深さ',
            '谷と谷の間の山が明確',
            'ネックラインのブレイクで確定',
            '上昇目標は谷の深さと同程度'
        ],
        data: [
            {open: 110, close: 105, high: 112, low: 95},
            {open: 105, close: 90, high: 108, low: 85},
            {open: 90, close: 95, high: 100, low: 80},
            {open: 95, close: 105, high: 110, low: 90},
            {open: 105, close: 98, high: 108, low: 85},
            {open: 98, close: 85, high: 102, low: 80},
            {open: 85, close: 90, high: 95, low: 78},
            {open: 90, close: 105, high: 115, low: 88},
            {open: 105, close: 115, high: 120, low: 100}
        ]
    },
    {
        id: 'symmetric-triangle',
        name: '対称三角形',
        type: 'continuation',
        badge: 'high',
        description: '高値が下降し、安値が上昇して、徐々に収束していくパターン。相場の迷いを示しますが、三角形の頂点に向かってボラティリティが低下し、ブレイク時には大きな値動きが期待できます。',
        keyPoints: [
            '高値と安値が同じ速度で接近',
            'ボラティリティが徐々に減少',
            'ブレイク方向がトレンドを示唆',
            '頂点付近でのブレイクが最も重要'
        ],
        data: [
            {open: 100, close: 102, high: 110, low: 95},
            {open: 102, close: 105, high: 112, low: 100},
            {open: 105, close: 103, high: 108, low: 102},
            {open: 103, close: 106, high: 108, low: 103},
            {open: 106, close: 104, high: 107, low: 104},
            {open: 104, close: 105, high: 106, low: 104},
            {open: 105, close: 108, high: 109, low: 105},
            {open: 108, close: 120, high: 125, low: 104},
            {open: 120, close: 125, high: 128, low: 118}
        ]
    },
    {
        id: 'ascending-triangle',
        name: 'アセンディングトライアングル',
        type: 'continuation',
        badge: 'high',
        description: 'レジスタンスがほぼ水平に推移しながら、サポートが段々上昇していくパターン。買い圧力が強いことを示し、上値ブレイクで継続買いシグナル。上昇トレンドの途中で出現すれば強気。',
        keyPoints: [
            '上値（レジスタンス）が水平',
            '下値（サポート）が段々上昇',
            '買い圧力が優勢',
            '上値ブレイクで上昇が加速'
        ],
        data: [
            {open: 100, close: 102, high: 108, low: 98},
            {open: 102, close: 100, high: 110, low: 100},
            {open: 100, close: 105, high: 110, low: 102},
            {open: 105, close: 102, high: 110, low: 104},
            {open: 102, close: 106, high: 110, low: 105},
            {open: 106, close: 103, high: 110, low: 106},
            {open: 103, close: 107, high: 110, low: 107},
            {open: 107, close: 108, high: 110, low: 108},
            {open: 108, close: 115, high: 118, low: 108},
            {open: 115, close: 120, high: 125, low: 115}
        ]
    },
    {
        id: 'descending-triangle',
        name: 'ディセンディングトライアングル',
        type: 'continuation',
        badge: 'high',
        description: 'サポートがほぼ水平に推移しながら、レジスタンスが段々下降していくパターン。売り圧力が強いことを示し、下値ブレイクで継続売りシグナル。下降トレンドの途中で出現すれば弱気。',
        keyPoints: [
            '下値（サポート）が水平',
            '上値（レジスタンス）が段々下降',
            '売り圧力が優勢',
            '下値ブレイクで下降が加速'
        ],
        data: [
            {open: 110, close: 108, high: 115, low: 100},
            {open: 108, close: 110, high: 112, low: 100},
            {open: 110, close: 105, high: 110, low: 100},
            {open: 105, close: 108, high: 110, low: 100},
            {open: 108, close: 104, high: 108, low: 100},
            {open: 104, close: 106, high: 107, low: 100},
            {open: 106, close: 103, high: 105, low: 100},
            {open: 103, close: 102, high: 104, low: 100},
            {open: 102, close: 90, high: 102, low: 85},
            {open: 90, close: 80, high: 92, low: 75}
        ]
    },
    {
        id: 'flag',
        name: 'フラッグ',
        type: 'continuation',
        badge: 'high',
        description: '急激な値動き（ポール）の後、小さな平行四辺形で休止（フラッグ）するパターン。強いトレンドが一時停止しているだけで、フラッグ突破後にトレンドが継続。',
        keyPoints: [
            'ポール部分の急激な値動きが重要',
            'フラッグ内のボラティリティが低い',
            '形成期間は数日～数週間',
            'ポール部分の高さ ≒ ブレイク後の値動き'
        ],
        data: [
            {open: 100, close: 102, high: 103, low: 98},
            {open: 102, close: 110, high: 112, low: 100},
            {open: 110, close: 118, high: 120, low: 108},
            {open: 118, close: 130, high: 135, low: 116},
            {open: 130, close: 128, high: 132, low: 127},
            {open: 128, close: 129, high: 131, low: 128},
            {open: 129, close: 127, high: 130, low: 126},
            {open: 127, close: 128, high: 130, low: 127},
            {open: 128, close: 140, high: 142, low: 128},
            {open: 140, close: 145, high: 148, low: 138}
        ]
    },
    {
        id: 'pennant',
        name: 'ペナント',
        type: 'continuation',
        badge: 'medium',
        description: 'フラッグよりも小さく、急速に収束していく三角形。短期的なエネルギーの蓄積を示し、ブレイク時には大きなボラティリティが期待できます。',
        keyPoints: [
            'フラッグより急速に収束',
            '形成期間は1～2週間と短い',
            '収束が早いほどボラティリティが高い',
            'トレンド継続が高確率'
        ],
        data: [
            {open: 100, close: 105, high: 106, low: 98},
            {open: 105, close: 115, high: 118, low: 103},
            {open: 115, close: 125, high: 130, low: 114},
            {open: 125, close: 128, high: 130, low: 126},
            {open: 128, close: 127, high: 129, low: 127},
            {open: 127, close: 128, high: 128, low: 127},
            {open: 128, close: 138, high: 140, low: 128},
            {open: 138, close: 145, high: 148, low: 138}
        ]
    },
    {
        id: 'wedge',
        name: 'ウェッジ',
        type: 'continuation',
        badge: 'medium',
        description: '高値と安値の両方が同じ方向に傾斜していくパターン。アップウェッジは売りシグナル、ダウンウェッジは買いシグナル。トレンドの疲弊と反転を示唆します。',
        keyPoints: [
            '両線が同じ方向に傾斜',
            'アップウェッジ：両線が下降（売り）',
            'ダウンウェッジ：両線が上昇（買い）',
            'トレンド疲弱の兆候'
        ],
        data: [
            {open: 100, close: 105, high: 112, low: 98},
            {open: 105, close: 110, high: 115, low: 102},
            {open: 110, close: 108, high: 113, low: 105},
            {open: 108, close: 112, high: 115, low: 106},
            {open: 112, close: 110, high: 113, low: 108},
            {open: 110, close: 111, high: 112, low: 108},
            {open: 111, close: 95, high: 111, low: 90},
            {open: 95, close: 85, high: 98, low: 80}
        ]
    },
    {
        id: 'rectangle',
        name: 'レクタングル',
        type: 'continuation',
        badge: 'high',
        description: '上値と下値が平行に推移して、四角形を形成するパターン。トレンド途中での休止を示し、上下いずれかのブレイクでトレンド継続。サポートとレジスタンスが明確。',
        keyPoints: [
            '上値（レジスタンス）がほぼ水平',
            '下値（サポート）がほぼ水平',
            'ボックス内での反発が何度も発生',
            'ブレイク後の値動き ≒ ボックスの高さ'
        ],
        data: [
            {open: 100, close: 105, high: 110, low: 98},
            {open: 105, close: 102, high: 110, low: 100},
            {open: 102, close: 108, high: 110, low: 100},
            {open: 108, close: 104, high: 110, low: 100},
            {open: 104, close: 106, high: 110, low: 100},
            {open: 106, close: 103, high: 110, low: 100},
            {open: 103, close: 107, high: 110, low: 100},
            {open: 107, close: 120, high: 125, low: 100}
        ]
    },
    {
        id: 'inverse-hs',
        name: '逆ヘッドアンドショルダーズ',
        type: 'reversal',
        badge: 'high',
        description: 'ヘッドアンドショルダーズの逆パターン。左肩、頭、右肩の3つの谷を形成する買いシグナル。ダウントレンドの終わりを示唆し、ネックラインを上抜けで確定。',
        keyPoints: [
            '3つの谷を形成',
            '頭が最も低く、両肩はほぼ同じ深さ',
            'ネックラインをはっきり上抜けがシグナル',
            '上昇目標はネックライン - 頭の深さ分'
        ],
        data: [
            {open: 110, close: 105, high: 115, low: 95},
            {open: 105, close: 90, high: 108, low: 80},
            {open: 90, close: 95, high: 100, low: 75},
            {open: 95, close: 75, high: 100, low: 65},
            {open: 75, close: 85, high: 95, low: 60},
            {open: 85, close: 95, high: 100, low: 80},
            {open: 95, close: 90, high: 105, low: 85},
            {open: 90, close: 100, high: 110, low: 88},
            {open: 100, close: 110, high: 120, low: 98}
        ]
    },
    {
        id: 'triple-bottom',
        name: 'トリプルボトム',
        type: 'reversal',
        badge: 'medium',
        description: '3度の試験を示す3つの同じ深さの谷。売り勢力が何度も下値を試しますが、その度に反発される形。最終的にネックラインを上抜けると強い買いシグナル。',
        keyPoints: [
            '3つの谷がほぼ同じ深さ',
            '形成に時間がかかる',
            '3度目の試験失敗が重要',
            '上昇目標は谷の深さの2倍程度'
        ],
        data: [
            {open: 110, close: 108, high: 112, low: 100},
            {open: 108, close: 92, high: 110, low: 85},
            {open: 92, close: 98, high: 105, low: 80},
            {open: 98, close: 92, high: 100, low: 85},
            {open: 92, close: 98, high: 105, low: 80},
            {open: 98, close: 92, high: 100, low: 85},
            {open: 92, close: 102, high: 108, low: 88},
            {open: 102, close: 110, high: 115, low: 100},
            {open: 110, close: 120, high: 125, low: 108}
        ]
    }
];

function drawCandleChart(canvasId, dataPoints, title) {
    const canvas = document.getElementById(canvasId);
    if (!canvas) return;

    const ctx = canvas.getContext('2d');
    const width = canvas.width;
    const height = canvas.height;
    const padding = 50;

    // Background
    ctx.fillStyle = '#ffffff';
    ctx.fillRect(0, 0, width, height);

    // Grid lines
    ctx.strokeStyle = '#e5e7eb';
    ctx.lineWidth = 1;
    const gridY = 8;
    for (let i = 0; i <= gridY; i++) {
        const y = padding + (height - 2 * padding) * (i / gridY);
        ctx.beginPath();
        ctx.moveTo(padding, y);
        ctx.lineTo(width - padding, y);
        ctx.stroke();
    }

    // Calculate scale
    const maxPrice = Math.max(...dataPoints.map(d => d.high));
    const minPrice = Math.min(...dataPoints.map(d => d.low));
    const priceRange = maxPrice - minPrice || 1;
    const chartWidth = width - 2 * padding;
    const chartHeight = height - 2 * padding;
    const candleWidth = (chartWidth / dataPoints.length) * 0.7;

    // Draw candles
    dataPoints.forEach((candle, index) => {
        const x = padding + (index * chartWidth / dataPoints.length) + (chartWidth / dataPoints.length / 2);
        const openY = padding + chartHeight - ((candle.open - minPrice) / priceRange * chartHeight);
        const closeY = padding + chartHeight - ((candle.close - minPrice) / priceRange * chartHeight);
        const highY = padding + chartHeight - ((candle.high - minPrice) / priceRange * chartHeight);
        const lowY = padding + chartHeight - ((candle.low - minPrice) / priceRange * chartHeight);

        // Wick
        ctx.strokeStyle = '#999';
        ctx.lineWidth = 1;
        ctx.beginPath();
        ctx.moveTo(x, highY);
        ctx.lineTo(x, lowY);
        ctx.stroke();

        // Body
        const isUp = candle.close >= candle.open;
        ctx.fillStyle = isUp ? '#10b981' : '#ef4444';
        ctx.strokeStyle = isUp ? '#059669' : '#dc2626';
        ctx.lineWidth = 1;

        const bodyTop = Math.min(openY, closeY);
        const bodyBottom = Math.max(openY, closeY);
        const bodyHeight = Math.max(bodyBottom - bodyTop, 2);

        ctx.fillRect(x - candleWidth / 2, bodyTop, candleWidth, bodyHeight);
        ctx.strokeRect(x - candleWidth / 2, bodyTop, candleWidth, bodyHeight);
    });

    // Axes
    ctx.strokeStyle = '#1f2937';
    ctx.lineWidth = 2;
    ctx.beginPath();
    ctx.moveTo(padding, padding);
    ctx.lineTo(padding, height - padding);
    ctx.lineTo(width - padding, height - padding);
    ctx.stroke();

    // Title
    ctx.fillStyle = '#1f2937';
    ctx.font = 'bold 14px sans-serif';
    ctx.fillText(title, padding + 10, padding - 20);
}

function filterPattern(type) {
    const gallery = document.getElementById('galleryGrid');
    const items = gallery.querySelectorAll('.gallery-item');

    items.forEach(item => {
        if (type === 'all') {
            item.classList.remove('hidden');
        } else {
            const itemType = item.dataset.type;
            if (itemType === type) {
                item.classList.remove('hidden');
            } else {
                item.classList.add('hidden');
            }
        }
    });

    // Update button states
    document.querySelectorAll('.filter-btn').forEach(btn => {
        btn.classList.remove('active');
    });
    event.target.classList.add('active');
}

function createGalleryItem(pattern) {
    const item = document.createElement('div');
    item.className = 'gallery-item';
    item.dataset.type = pattern.type;

    const headerClass = pattern.type === 'reversal'
        ? (pattern.id.includes('inverse') || pattern.id.includes('bottom') ? 'downtrend' : 'uptrend')
        : 'continuation';

    const badgeClass = pattern.badge === 'high' ? 'high' : pattern.badge === 'medium' ? 'medium' : 'low';

    item.innerHTML = `
        <div class="gallery-header ${headerClass}">
            <h2>${pattern.name}</h2>
            <p>${pattern.type === 'reversal' ? '反転パターン' : '継続パターン'}</p>
            <div class="reliability-badge ${badgeClass}">
                信頼度: ${pattern.badge === 'high' ? '高' : '中'}
            </div>
        </div>
        <div class="chart-container">
            <canvas id="canvas-${pattern.id}" width="600" height="320" style="width: 100%; height: auto;"></canvas>
        </div>
        <div class="description">
            <h3>パターンの説明</h3>
            <div class="description-text">${pattern.description}</div>
            <div class="key-points">
                <h4>重要なポイント</h4>
                <ul>
                    ${pattern.keyPoints.map(point => `<li>${point}</li>`).join('')}
                </ul>
            </div>
        </div>
    `;

    return item;
}

document.addEventListener('DOMContentLoaded', function() {
    const gallery = document.getElementById('galleryGrid');

    patterns.forEach(pattern => {
        const item = createGalleryItem(pattern);
        gallery.appendChild(item);

        // Draw chart after element is added
        setTimeout(() => {
            drawCandleChart(`canvas-${pattern.id}`, pattern.data, pattern.name);
        }, 100);
    });
});
