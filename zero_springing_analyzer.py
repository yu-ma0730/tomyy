"""
Zero Springing Trading Method Analyzer
ゼロスプリング手法 - FX Trading Signal Generator
"""

from typing import List, Dict, Tuple, Optional
from dataclasses import dataclass
from enum import Enum
import json


class TrendDirection(Enum):
    """トレンド方向"""
    UP = "uptrend"
    DOWN = "downtrend"
    NEUTRAL = "neutral"


class SignalStatus(Enum):
    """シグナルステータス"""
    NO_SIGNAL = "no_signal"
    TREND_CONFIRMED = "trend_confirmed"
    WAITING_RCI_DROP = "waiting_rci_drop"
    RCI_DROPPED = "rci_dropped"
    ENTRY_READY = "entry_ready"
    ENTRY_SIGNAL = "entry_signal"


@dataclass
class CandleData:
    """ローソク足データ"""
    open: float
    high: float
    low: float
    close: float
    timestamp: int
    volume: Optional[float] = None

    def is_bullish(self) -> bool:
        """上昇ローソク"""
        return self.close > self.open

    def is_bearish(self) -> bool:
        """下降ローソク"""
        return self.close < self.open

    def body_size(self) -> float:
        """ローソク足の実体"""
        return abs(self.close - self.open)

    def range(self) -> float:
        """高値と安値の幅"""
        return self.high - self.low


@dataclass
class RCIData:
    """RCI指標データ"""
    value: float
    timestamp: int
    previous_value: Optional[float] = None

    def is_positive_zone(self) -> bool:
        """正のゾーン (+0以上)"""
        return self.value >= 0

    def is_negative_zone(self) -> bool:
        """負のゾーン (-0未満)"""
        return self.value < 0

    def is_oversold(self) -> bool:
        """過売ゾーン (-30% ~ -60%)"""
        return -60 <= self.value <= -30

    def is_crossing_zero_up(self) -> bool:
        """0ラインを上抜け"""
        if self.previous_value is None:
            return False
        return self.previous_value < 0 and self.value >= 0

    def is_crossing_zero_down(self) -> bool:
        """0ラインを下抜け"""
        if self.previous_value is None:
            return False
        return self.previous_value >= 0 and self.value < 0


class TrendAnalyzer:
    """トレンド分析 - 4時間足"""

    @staticmethod
    def analyze_uptrend(candles: List[CandleData]) -> Tuple[bool, Dict]:
        """
        上昇トレンドの確認

        条件:
        1. 移動平均線が価格より上にある
        2. 高値と安値が上昇している
        3. 全体的に買いが優勢な形になっている
        """
        if len(candles) < 3:
            return False, {"reason": "insufficient_data"}

        recent = candles[-3:]  # 直近3本

        # 直近3本が上昇しているか確認
        is_rising = all(candles[i].close < candles[i + 1].close
                       for i in range(len(recent) - 1))

        # 高値と安値が切り上がっているか
        highs_rising = recent[-1].high > recent[-2].high > recent[-3].high
        lows_rising = recent[-1].low > recent[-2].low > recent[-3].low

        # 買いの勢いを確認
        bullish_ratio = sum(1 for c in recent if c.is_bullish()) / len(recent)

        is_uptrend = is_rising and highs_rising and lows_rising and bullish_ratio > 0.5

        return is_uptrend, {
            "is_rising": is_rising,
            "highs_rising": highs_rising,
            "lows_rising": lows_rising,
            "bullish_ratio": bullish_ratio
        }

    @staticmethod
    def analyze_downtrend(candles: List[CandleData]) -> Tuple[bool, Dict]:
        """下降トレンドの確認"""
        if len(candles) < 3:
            return False, {"reason": "insufficient_data"}

        recent = candles[-3:]

        is_falling = all(candles[i].close > candles[i + 1].close
                        for i in range(len(recent) - 1))

        highs_falling = recent[-1].high < recent[-2].high < recent[-3].high
        lows_falling = recent[-1].low < recent[-2].low < recent[-3].low

        bearish_ratio = sum(1 for c in recent if c.is_bearish()) / len(recent)

        is_downtrend = is_falling and highs_falling and lows_falling and bearish_ratio > 0.5

        return is_downtrend, {
            "is_falling": is_falling,
            "highs_falling": highs_falling,
            "lows_falling": lows_falling,
            "bearish_ratio": bearish_ratio
        }


class RCIAnalyzer:
    """RCI指標分析 - 15分足"""

    @staticmethod
    def analyze_entry_signal(rci_data: RCIData) -> Tuple[bool, str]:
        """
        エントリーシグナル分析

        条件:
        1. RCIが-30%～-60%に下がった
        2. その後、0ラインを上抜ける
        """
        if rci_data.is_crossing_zero_up():
            return True, "entry_ready"
        return False, "waiting"

    @staticmethod
    def check_signal_status(rci_list: List[RCIData]) -> Dict:
        """シグナル状態を確認"""
        if len(rci_list) < 2:
            return {"status": SignalStatus.NO_SIGNAL.value}

        latest_rci = rci_list[-1]

        # 0ラインを上抜けているか
        if latest_rci.is_crossing_zero_up():
            return {
                "status": SignalStatus.ENTRY_SIGNAL.value,
                "current_rci": latest_rci.value,
                "message": "Entry signal detected - RCI crossed 0 line upward"
            }

        # 過売ゾーンか
        if latest_rci.is_oversold():
            return {
                "status": SignalStatus.WAITING_RCI_DROP.value,
                "current_rci": latest_rci.value,
                "message": "Waiting for RCI to cross 0 line upward"
            }

        # 0未満か
        if latest_rci.is_negative_zone():
            return {
                "status": SignalStatus.RCI_DROPPED.value,
                "current_rci": latest_rci.value,
                "message": "RCI is below 0 - Waiting for upward movement"
            }

        return {
            "status": SignalStatus.NO_SIGNAL.value,
            "current_rci": latest_rci.value
        }


class StopLossCalculator:
    """ストップロス計算"""

    @staticmethod
    def calculate_stop_loss(candles_15min: List[CandleData],
                           entry_price: float) -> Dict:
        """
        ストップロスポイントを計算

        配置位置:
        - 反発したロング足の安値
        - 直近のサポート
        - 押し目を作った一番下の価格
        """
        if len(candles_15min) < 3:
            return {"error": "insufficient_data"}

        recent = candles_15min[-5:]  # 直近5本を確認

        # 直近の安値を取得
        recent_low = min(c.low for c in recent)

        # サポートレベルを検出
        support_candidates = []
        for i in range(len(recent) - 1):
            if recent[i].low < recent[i - 1].low if i > 0 else True:
                support_candidates.append(recent[i].low)

        stop_loss_price = min(support_candidates) if support_candidates else recent_low

        pips_distance = (entry_price - stop_loss_price) * 10000  # pipsに変換

        return {
            "stop_loss_price": round(stop_loss_price, 5),
            "pips_distance": round(pips_distance, 1),
            "recent_low": recent_low
        }


class ProfitTargetCalculator:
    """利確目標を計算"""

    @staticmethod
    def calculate_profit_targets(entry_price: float,
                                stop_loss_distance: float) -> Dict:
        """
        利確目標を計算

        利確1: ストップロス幅の0.6～0.8倍
        利確2: ストップロス幅の2倍
        """

        # 初期設定
        profit1_distance = stop_loss_distance * 0.7  # 中間値
        profit2_distance = stop_loss_distance * 2

        profit1_price = entry_price + profit1_distance / 10000
        profit2_price = entry_price + profit2_distance / 10000

        return {
            "profit1": {
                "price": round(profit1_price, 5),
                "pips": round(profit1_distance, 1),
                "description": "Take 50% profit here"
            },
            "profit2": {
                "price": round(profit2_price, 5),
                "pips": round(profit2_distance, 1),
                "description": "Take remaining 50% profit here"
            },
            "entry_price": entry_price
        }

    @staticmethod
    def calculate_beginner_targets(entry_price: float) -> Dict:
        """初心者向けの固定ルール"""
        stop_loss_price = entry_price - 0.0050  # 50pips下
        profit_price = entry_price + 0.0100     # 100pips上

        return {
            "stop_loss": {
                "price": round(stop_loss_price, 5),
                "pips": 50
            },
            "profit": {
                "price": round(profit_price, 5),
                "pips": 100
            },
            "ratio": 1  # 1:2 リスク:リワード
        }


class ZeroSpringAnalyzer:
    """ゼロスプリング手法メインアナライザー"""

    def __init__(self):
        self.trend_analyzer = TrendAnalyzer()
        self.rci_analyzer = RCIAnalyzer()
        self.stop_loss_calc = StopLossCalculator()
        self.profit_target_calc = ProfitTargetCalculator()

    def analyze(self,
                candles_4h: List[CandleData],
                candles_15m: List[CandleData],
                rci_data: List[RCIData]) -> Dict:
        """
        完全な分析を実行

        手順:
        1. 4時間足で上昇トレンドを確認
        2. 15分足でRCI分析
        3. エントリーシグナルを確認
        4. ストップロスと利確を計算
        """

        # Step 1: トレンド確認
        is_uptrend, trend_analysis = self.trend_analyzer.analyze_uptrend(candles_4h)

        if not is_uptrend:
            return {
                "status": SignalStatus.NO_SIGNAL.value,
                "reason": "4-hour uptrend not confirmed",
                "trend_analysis": trend_analysis
            }

        # Step 2: RCI分析
        rci_status = self.rci_analyzer.check_signal_status(rci_data)

        # Step 3: シグナル確認
        if rci_status.get("status") == SignalStatus.ENTRY_SIGNAL.value:
            latest_15m_close = candles_15m[-1].close if candles_15m else None

            # Stop Loss & Profit Targets
            sl_calc = self.stop_loss_calc.calculate_stop_loss(
                candles_15m,
                latest_15m_close
            )

            pt_calc = self.profit_target_calc.calculate_profit_targets(
                latest_15m_close,
                sl_calc.get("pips_distance", 0)
            )

            return {
                "status": SignalStatus.ENTRY_SIGNAL.value,
                "signal": "LONG ENTRY",
                "current_price": latest_15m_close,
                "stop_loss": sl_calc,
                "profit_targets": pt_calc,
                "trend_analysis": trend_analysis,
                "rci_analysis": rci_status,
                "risk_reward_ratio": round(
                    (pt_calc["profit2"]["pips"] / sl_calc.get("pips_distance", 1)), 2
                )
            }

        return {
            "status": rci_status.get("status", SignalStatus.NO_SIGNAL.value),
            "trend_analysis": trend_analysis,
            "rci_analysis": rci_status
        }

    def analyze_with_beginner_mode(self,
                                    candles_4h: List[CandleData],
                                    candles_15m: List[CandleData],
                                    rci_data: List[RCIData]) -> Dict:
        """初心者向けモード（固定ルール）"""

        # 基本分析
        analysis = self.analyze(candles_4h, candles_15m, rci_data)

        if analysis.get("status") == SignalStatus.ENTRY_SIGNAL.value:
            entry_price = analysis.get("current_price")
            beginner_targets = self.profit_target_calc.calculate_beginner_targets(
                entry_price
            )

            analysis["beginner_mode"] = {
                "enabled": True,
                "stop_loss": beginner_targets["stop_loss"],
                "profit": beginner_targets["profit"],
                "risk_reward_ratio": beginner_targets["ratio"]
            }

        return analysis


def example_usage():
    """使用例"""

    # サンプルデータ
    candles_4h = [
        CandleData(open=100.0, high=102.0, low=99.5, close=101.5, timestamp=1),
        CandleData(open=101.5, high=103.0, low=101.0, close=102.5, timestamp=2),
        CandleData(open=102.5, high=104.0, low=102.0, close=103.5, timestamp=3),
    ]

    candles_15m = [
        CandleData(open=103.5, high=103.8, low=103.0, close=103.2, timestamp=1),
        CandleData(open=103.2, high=103.5, low=102.9, close=103.0, timestamp=2),
        CandleData(open=103.0, high=103.3, low=102.8, close=103.1, timestamp=3),
    ]

    rci_data = [
        RCIData(value=-45.0, timestamp=1),
        RCIData(value=-35.0, timestamp=2, previous_value=-45.0),
        RCIData(value=5.0, timestamp=3, previous_value=-35.0),  # 0ラインクロス
    ]

    analyzer = ZeroSpringAnalyzer()
    result = analyzer.analyze(candles_4h, candles_15m, rci_data)

    print(json.dumps(result, indent=2, ensure_ascii=False, default=str))


if __name__ == "__main__":
    example_usage()
