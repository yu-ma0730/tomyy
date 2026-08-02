// Indicator Data
const indicators = [
    {
        id: 'sma',
        name: '単純移動平均 (SMA)',
        category: 'trend',
        description: '過去一定期間の平均価格。トレンド判断に最適。',
        buySignal: '短期SMAが長期SMAを上抜けた時（ゴールデンクロス）',
        sellSignal: '短期SMAが長期SMAを下抜けた時（デッドクロス）',
        caution: 'トレンドレスの相場では機能しにくい'
    },
    {
        id: 'ema',
        name: '指数移動平均 (EMA)',
        category: 'trend',
        description: '最新の価格に重点を置いた移動平均。反応が素早い。',
        buySignal: '価格がEMAの上にある時、EMAが上昇している場合',
        sellSignal: '価格がEMAの下にある時、EMAが下降している場合',
        caution: 'ダマシが多いため、他の指標と組み合わせ必須'
    },
    {
        id: 'macd',
        name: 'MACD',
        category: 'momentum',
        description: 'トレンド転換を判定する指標。MACDラインとシグナルラインの交差を見る。',
        buySignal: 'MACDがシグナルラインを上抜けた時',
        sellSignal: 'MACDがシグナルラインを下抜けた時',
        caution: 'タイムラグがあるため、早期入場ができない'
    },
    {
        id: 'rsi',
        name: 'RSI',
        category: 'momentum',
        description: '買われすぎ・売られすぎを判定。0-100の範囲で推移。',
        buySignal: 'RSIが30以下から上昇した時（売られすぎからの反発）',
        sellSignal: 'RSIが70以上から下降した時（買われすぎからの反落）',
        caution: 'トレンドが強い時は70以上で張り付き、反転しない'
    },
    {
        id: 'stoch',
        name: 'ストキャスティクス',
        category: 'momentum',
        description: 'RSIと似た買われすぎ・売られすぎを判定。より敏感に反応。',
        buySignal: 'Kラインが20以下から上昇し、Dラインを上抜けた時',
        sellSignal: 'Kラインが80以上から下降し、Dラインを下抜けた時',
        caution: 'ダイバージェンスの確認が重要'
    },
    {
        id: 'bb',
        name: 'ボリンジャーバンド',
        category: 'volatility',
        description: 'ボラティリティを視覚化。バンド内での価格変動を示す。',
        buySignal: '価格が下部バンドに接近した時（反発の可能性）',
        sellSignal: '価格が上部バンドに接近した時（反落の可能性）',
        caution: 'バンド外での価格変動も多く、単独では信頼度が低い'
    },
    {
        id: 'atr',
        name: 'ATR（平均真実範囲）',
        category: 'volatility',
        description: 'ボラティリティの大きさを測定。ストップロスの設定に有効。',
        buySignal: 'ATRが高い時に他のシグナルが出た場合（大きな値動き予想）',
        sellSignal: 'ATRが低い時は動きが小さいため、大型トレード向かず',
        caution: 'ボラティリティ測定のみで売買シグナルを生成しない'
    },
    {
        id: 'support-resistance',
        name: 'サポート・レジスタンス',
        category: 'trend',
        description: '過去の反発ポイントを水平線で示す。最も基本的な分析手法。',
        buySignal: 'サポートレベルでの反発時、または突破時の買い続け',
        sellSignal: 'レジスタンスレベルでの反発時、または突破時の売り続け',
        caution: 'レベルの引き方によって結果が大きく変わる'
    },
    {
        id: 'volume',
        name: '出来高',
        category: 'volume',
        description: 'トレンドの強さを確認。増加した出来高はシグナルの信頼度を上げる。',
        buySignal: '上昇トレンドに出来高が伴っている場合',
        sellSignal: '下降トレンドに出来高が伴っている場合',
        caution: '出来高だけではシグナルにならない'
    },
    {
        id: 'obv',
        name: 'OBV（オンバランスボリューム）',
        category: 'volume',
        description: '出来高を累積して、買い売り圧力を判定する。',
        buySignal: 'OBVが上昇トレンドを形成し、新高値更新',
        sellSignal: 'OBVが下降トレンドを形成し、新安値更新',
        caution: 'ダイバージェンスの確認が重要'
    },
    {
        id: 'adx',
        name: 'ADX',
        category: 'trend',
        description: 'トレンドの強さを判定。25以上が強いトレンド。',
        buySignal: 'ADXが25以上で上昇、且つ+DIが-DIより上',
        sellSignal: 'ADXが25以上で上昇、且つ-DIが+DIより上',
        caution: 'トレンドの強さのみで、方向性は別指標で確認'
    },
    {
        id: 'ichimoku',
        name: '一目均衡表',
        category: 'trend',
        description: '複数の移動平均を組み合わせた総合指標。日本発祥。',
        buySignal: '価格が雲の上にあり、雲が上昇している場合',
        sellSignal: '価格が雲の下にあり、雲が下降している場合',
        caution: 'パラメータが複雑で設定が難しい'
    },
    {
        id: 'pivot',
        name: 'ピボット',
        category: 'trend',
        description: '前日の高値・安値・終値から、本日の反発ポイントを計算。',
        buySignal: 'サポート1以下からピボットを上抜けた時',
        sellSignal: 'レジスタンス1以上からピボットを下抜けた時',
        caution: '値動きが限定的で大きなトレードには向かない'
    }
];

let selectedIndicators = [];
let currentFilter = 'all';

function filterIndicators(category) {
    currentFilter = category;
    renderIndicators();

    // Update filter buttons
    document.querySelectorAll('.filter-btn').forEach(btn => {
        btn.classList.remove('active');
    });
    event.target.classList.add('active');
}

function renderIndicators() {
    const list = document.getElementById('indicatorList');
    list.innerHTML = '';

    const filtered = currentFilter === 'all'
        ? indicators
        : indicators.filter(ind => ind.category === currentFilter);

    filtered.forEach(indicator => {
        const isSelected = selectedIndicators.some(s => s.id === indicator.id);

        const item = document.createElement('div');
        item.className = `indicator-item ${isSelected ? 'checked' : ''}`;

        const categoryLabel = {
            trend: 'トレンド',
            momentum: 'モメンタム',
            volatility: 'ボラティリティ',
            volume: '出来高'
        }[indicator.category];

        item.innerHTML = `
            <input type="checkbox" class="indicator-checkbox" ${isSelected ? 'checked' : ''}
                   onchange="toggleIndicator('${indicator.id}')">
            <div class="indicator-content">
                <h3>${indicator.name}</h3>
                <p>${indicator.description}</p>
                <span class="category-badge ${indicator.category}">${categoryLabel}</span>
            </div>
        `;

        list.appendChild(item);
    });
}

function toggleIndicator(id) {
    const indicator = indicators.find(ind => ind.id === id);
    const index = selectedIndicators.findIndex(ind => ind.id === id);

    if (index > -1) {
        selectedIndicators.splice(index, 1);
    } else {
        selectedIndicators.push(indicator);
    }

    renderIndicators();
    updateStrategyDisplay();
}

function updateStrategyDisplay() {
    const container = document.getElementById('selectedIndicators');
    const strategyDisplay = document.getElementById('strategyDisplay');

    if (selectedIndicators.length === 0) {
        container.innerHTML = '<div class="empty-state"><p>👈 左からインジケーターを選択してください</p></div>';
        strategyDisplay.style.display = 'none';
        return;
    }

    // Display selected indicators
    container.innerHTML = `
        <div class="selected-list">
            ${selectedIndicators.map((ind, idx) => `
                <div class="selected-item">
                    <span>${ind.name}</span>
                    <button class="remove-btn" onclick="removeIndicator('${ind.id}')">削除</button>
                </div>
            `).join('')}
        </div>
    `;

    // Generate strategy
    generateStrategy();
    strategyDisplay.style.display = 'block';
}

function removeIndicator(id) {
    selectedIndicators = selectedIndicators.filter(ind => ind.id !== id);
    renderIndicators();
    updateStrategyDisplay();
}

function generateStrategy() {
    const buySignals = selectedIndicators
        .map(ind => `<li>${ind.buySignal}</li>`)
        .join('');

    const sellSignals = selectedIndicators
        .map(ind => `<li>${ind.sellSignal}</li>`)
        .join('');

    const cautions = selectedIndicators
        .map(ind => `<li>${ind.caution}</li>`)
        .join('');

    document.getElementById('buySignals').innerHTML = buySignals;
    document.getElementById('sellSignals').innerHTML = sellSignals;
    document.getElementById('cautions').innerHTML = cautions;
}

function saveStrategy() {
    const name = document.getElementById('strategyName').value.trim();

    if (!name) {
        alert('戦略名を入力してください');
        return;
    }

    if (selectedIndicators.length === 0) {
        alert('インジケーターを1つ以上選択してください');
        return;
    }

    const strategy = {
        name: name,
        indicators: selectedIndicators.map(ind => ind.name),
        data: JSON.stringify(selectedIndicators)
    };

    // Get existing strategies
    let saved = JSON.parse(localStorage.getItem('strategies')) || [];

    // Avoid duplicates
    saved = saved.filter(s => s.name !== name);
    saved.push(strategy);

    localStorage.setItem('strategies', JSON.stringify(saved));
    alert(`「${name}」を保存しました！`);

    renderSavedStrategies();
}

function resetStrategy() {
    selectedIndicators = [];
    document.getElementById('strategyName').value = '';
    renderIndicators();
    updateStrategyDisplay();
}

function renderSavedStrategies() {
    const saved = JSON.parse(localStorage.getItem('strategies')) || [];

    if (saved.length === 0) {
        document.getElementById('savedStrategies').style.display = 'none';
        return;
    }

    document.getElementById('savedStrategies').style.display = 'block';

    const list = document.getElementById('savedList');
    list.innerHTML = saved.map(strategy => `
        <div class="saved-item">
            <div>
                <div class="saved-item-name">${strategy.name}</div>
                <div class="saved-item-indicators">${strategy.indicators.join(', ')}</div>
            </div>
            <div style="display: flex; gap: 0.5rem;">
                <button class="btn-custom btn-outline" onclick="loadStrategy('${strategy.name}')">読み込む</button>
                <button class="remove-btn" onclick="deleteStrategy('${strategy.name}')">削除</button>
            </div>
        </div>
    `).join('');
}

function loadStrategy(name) {
    const saved = JSON.parse(localStorage.getItem('strategies')) || [];
    const strategy = saved.find(s => s.name === name);

    if (!strategy) return;

    selectedIndicators = JSON.parse(strategy.data);
    document.getElementById('strategyName').value = name;

    renderIndicators();
    updateStrategyDisplay();

    // Scroll to strategy display
    document.getElementById('strategyDisplay').scrollIntoView({ behavior: 'smooth' });
}

function deleteStrategy(name) {
    if (!confirm(`「${name}」を削除しますか？`)) return;

    let saved = JSON.parse(localStorage.getItem('strategies')) || [];
    saved = saved.filter(s => s.name !== name);

    localStorage.setItem('strategies', JSON.stringify(saved));
    renderSavedStrategies();
}

// Initialize on page load
document.addEventListener('DOMContentLoaded', function() {
    renderIndicators();
    renderSavedStrategies();
});
