// Smooth scrolling for navigation links
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        e.preventDefault();
        const target = document.querySelector(this.getAttribute('href'));
        if (target) {
            target.scrollIntoView({
                behavior: 'smooth'
            });
        }
    });
});

// Active navigation update on page load
function updateActiveNav() {
    const currentPage = window.location.pathname.split('/').pop() || 'index.html';
    document.querySelectorAll('.nav-links a').forEach(link => {
        link.classList.remove('active');
        if (link.getAttribute('href') === currentPage) {
            link.classList.add('active');
        }
    });
}

document.addEventListener('DOMContentLoaded', updateActiveNav);

// Add animation to cards on scroll
const observerOptions = {
    threshold: 0.1,
    rootMargin: '0px 0px -50px 0px'
};

const observer = new IntersectionObserver(function(entries) {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            entry.target.style.animation = 'fadeInUp 0.6s ease forwards';
            observer.unobserve(entry.target);
        }
    });
}, observerOptions);

// Observe all cards and boxes
document.querySelectorAll('.card, .technique-card, .fundamental-card, .strategy-box, .info-box, .tip').forEach(element => {
    observer.observe(element);
});

// Canvas Chart Drawing Function
function drawCandleChart(canvasId, dataPoints, patternType) {
    const canvas = document.getElementById(canvasId);
    if (!canvas) return;

    const ctx = canvas.getContext('2d');
    const width = canvas.width;
    const height = canvas.height;
    const padding = 40;

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
    const candleWidth = chartWidth / (dataPoints.length * 1.5);

    // Draw candles
    dataPoints.forEach((candle, index) => {
        const x = padding + (index * chartWidth / dataPoints.length) + (chartWidth / dataPoints.length / 2);
        const openY = padding + chartHeight - ((candle.open - minPrice) / priceRange * chartHeight);
        const closeY = padding + chartHeight - ((candle.close - minPrice) / priceRange * chartHeight);
        const highY = padding + chartHeight - ((candle.high - minPrice) / priceRange * chartHeight);
        const lowY = padding + chartHeight - ((candle.low - minPrice) / priceRange * chartHeight);

        // Wick (shadow)
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

    // Draw axes
    ctx.strokeStyle = '#1f2937';
    ctx.lineWidth = 2;
    ctx.beginPath();
    ctx.moveTo(padding, padding);
    ctx.lineTo(padding, height - padding);
    ctx.lineTo(width - padding, height - padding);
    ctx.stroke();

    // Draw pattern indicator
    if (patternType) {
        ctx.fillStyle = '#f59e0b';
        ctx.font = 'bold 12px sans-serif';
        ctx.fillText(patternType, width - padding - 100, 30);
    }
}

// Initialize charts on page load
document.addEventListener('DOMContentLoaded', function() {
    // Head and Shoulders
    const hsData = [
        {open: 100, close: 95, high: 105, low: 90},
        {open: 95, close: 110, high: 115, low: 92},
        {open: 110, close: 105, high: 120, low: 100},
        {open: 105, close: 125, high: 130, low: 102},
        {open: 125, close: 115, high: 135, low: 110},
        {open: 115, close: 95, high: 118, low: 92},
        {open: 95, close: 110, high: 115, low: 90},
        {open: 110, close: 100, high: 112, low: 95},
        {open: 100, close: 85, high: 105, low: 80}
    ];

    if (document.getElementById('canvas-hs')) {
        drawCandleChart('canvas-hs', hsData, 'Head & Shoulders');
    }

    // Double Top
    const dtData = [
        {open: 100, close: 95, high: 105, low: 90},
        {open: 95, close: 105, high: 110, low: 92},
        {open: 105, close: 110, high: 115, low: 100},
        {open: 110, close: 100, high: 112, low: 95},
        {open: 100, close: 110, high: 115, low: 98},
        {open: 110, close: 105, high: 116, low: 102},
        {open: 105, close: 95, high: 108, low: 90},
        {open: 95, close: 85, high: 98, low: 80}
    ];

    if (document.getElementById('canvas-dt')) {
        drawCandleChart('canvas-dt', dtData, 'Double Top');
    }

    // Triangle
    const triData = [
        {open: 100, close: 102, high: 110, low: 95},
        {open: 102, close: 105, high: 112, low: 100},
        {open: 105, close: 103, high: 108, low: 102},
        {open: 103, close: 106, high: 108, low: 103},
        {open: 106, close: 104, high: 107, low: 104},
        {open: 104, close: 105, high: 106, low: 104},
        {open: 105, close: 120, high: 125, low: 104}
    ];

    if (document.getElementById('canvas-tri')) {
        drawCandleChart('canvas-tri', triData, 'Triangle');
    }
});

// Add animation styles
const style = document.createElement('style');
style.textContent = `
    @keyframes fadeInUp {
        from {
            opacity: 0;
            transform: translateY(30px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }
`;
document.head.appendChild(style);
