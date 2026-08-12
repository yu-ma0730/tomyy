//+------------------------------------------------------------------+
//|                        FX Trading Signals [1H/5M]                 |
//|                    MetaTrader 5 Custom Indicator                  |
//|                                                                    |
//| Environment Recognition: 1-Hour Timeframe                         |
//| Entry Signals: 5-Minute Timeframe                                 |
//| Symbols: USDJPY, EURJPY, EURUSD, XAUUSD                          |
//+------------------------------------------------------------------+
#property copyright "FX Trading Rules"
#property link      ""
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0

// Input parameters
input int    Lookback_Periods = 20;           // Lookback for swing high/low
input double Fib_Level_1 = 38.2;              // Fibonacci Level 1 (%)
input double Fib_Level_2 = 50.0;              // Fibonacci Level 2 (%)
input double Fib_Level_3 = 61.8;              // Fibonacci Level 3 (%)
input bool   Show_EMA = true;                 // Show EMA Lines
input bool   Show_Fib = true;                 // Show Fibonacci Levels
input bool   Show_Signals = true;             // Show Entry Signals
input bool   Show_Info_Panel = true;          // Show Info Panel
input bool   Use_Alerts = true;               // Enable Alerts
input int    Arrow_Size = 2;                  // Arrow Size (1=tiny, 5=large)

// Global variables
int    h1_handle, h5m_handle;
double ema10_1h[], ema20_1h[], ema40_1h[], ema80_1h[], ema200_1h[];
double ema10_5m[], ema20_5m[], ema40_5m[], ema80_5m[];
double close_1h[], high_1h[], low_1h[];
double close_5m[], high_5m[], low_5m[];

string symbol_short = "";
int    last_signal_bar = -1;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   // Request data handles
   h1_handle = iOpen(_Symbol, PERIOD_H1, 0);   // 1-hour
   h5m_handle = iOpen(_Symbol, PERIOD_M5, 0);  // 5-minute

   if(h1_handle == INVALID_HANDLE || h5m_handle == INVALID_HANDLE)
   {
      Alert("Failed to create indicator handles");
      return(INIT_FAILED);
   }

   symbol_short = _Symbol;

   Comment("FX Trading Signals [1H/5M] loaded");
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   Comment("");
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   // Copy data from both timeframes
   CopyClose(_Symbol, PERIOD_H1, 0, Lookback_Periods + 50, close_1h);
   CopyHigh(_Symbol, PERIOD_H1, 0, Lookback_Periods + 50, high_1h);
   CopyLow(_Symbol, PERIOD_H1, 0, Lookback_Periods + 50, low_1h);

   CopyClose(_Symbol, PERIOD_M5, 0, 100, close_5m);
   CopyHigh(_Symbol, PERIOD_M5, 0, 100, high_5m);
   CopyLow(_Symbol, PERIOD_M5, 0, 100, low_5m);

   // Calculate EMA for 1-hour timeframe
   CalculateEMA(_Symbol, PERIOD_H1, 10, close_1h, ema10_1h);
   CalculateEMA(_Symbol, PERIOD_H1, 20, close_1h, ema20_1h);
   CalculateEMA(_Symbol, PERIOD_H1, 40, close_1h, ema40_1h);
   CalculateEMA(_Symbol, PERIOD_H1, 80, close_1h, ema80_1h);
   CalculateEMA(_Symbol, PERIOD_H1, 200, close_1h, ema200_1h);

   // Calculate EMA for 5-minute timeframe
   CalculateEMA(_Symbol, PERIOD_M5, 10, close_5m, ema10_5m);
   CalculateEMA(_Symbol, PERIOD_M5, 20, close_5m, ema20_5m);
   CalculateEMA(_Symbol, PERIOD_M5, 40, close_5m, ema40_5m);
   CalculateEMA(_Symbol, PERIOD_M5, 80, close_5m, ema80_5m);

   // Analyze 1-hour environment
   bool   is_long_trend_1h = false;
   bool   is_short_trend_1h = false;
   bool   is_flat_1h = false;
   bool   is_initial_phase = false;
   bool   is_middle_phase = false;
   bool   is_end_phase = false;
   string phase_text = "";

   Analyze1HourEnvironment(close_1h, high_1h, low_1h, ema200_1h,
                           is_long_trend_1h, is_short_trend_1h, is_flat_1h,
                           is_initial_phase, is_middle_phase, is_end_phase, phase_text);

   // Analyze 5-minute setup
   bool   long_ema_setup = false;
   bool   short_ema_setup = false;
   bool   long_ema_position = false;
   bool   short_ema_position = false;

   Analyze5MinuteEMA(ema10_5m, ema20_5m, ema40_5m, ema80_5m,
                     close_5m, high_5m, low_5m,
                     long_ema_setup, short_ema_setup,
                     long_ema_position, short_ema_position);

   // Calculate Fibonacci levels
   double swing_high_1h = GetSwingHigh(high_1h, Lookback_Periods);
   double swing_low_1h = GetSwingLow(low_1h, Lookback_Periods);

   double fib_range = swing_high_1h - swing_low_1h;
   double fib_level1_long = swing_high_1h - (fib_range * Fib_Level_1 / 100);
   double fib_level2_long = swing_high_1h - (fib_range * Fib_Level_2 / 100);
   double fib_level3_long = swing_high_1h - (fib_range * Fib_Level_3 / 100);

   double fib_level1_short = swing_low_1h + (fib_range * Fib_Level_1 / 100);
   double fib_level2_short = swing_low_1h + (fib_range * Fib_Level_2 / 100);
   double fib_level3_short = swing_low_1h + (fib_range * Fib_Level_3 / 100);

   // Check Fibonacci touch
   double tolerance = _Point * 20;  // ~2 pips tolerance
   bool   fib_touch_long = IsPriceNearLevel(close_5m[0], fib_level1_long, tolerance) ||
                           IsPriceNearLevel(close_5m[0], fib_level2_long, tolerance) ||
                           IsPriceNearLevel(close_5m[0], fib_level3_long, tolerance);

   bool   fib_touch_short = IsPriceNearLevel(close_5m[0], fib_level1_short, tolerance) ||
                            IsPriceNearLevel(close_5m[0], fib_level2_short, tolerance) ||
                            IsPriceNearLevel(close_5m[0], fib_level3_short, tolerance);

   // Detect push low / return high
   bool   push_low_formed = (low_5m[0] == low_5m[1]) || (low_5m[1] < low_5m[0] && low_5m[1] < low_5m[2]);
   bool   return_high_formed = (high_5m[0] == high_5m[1]) || (high_5m[1] > high_5m[0] && high_5m[1] > high_5m[2]);
   bool   body_above_low = close_5m[0] > low_5m[0];
   bool   body_below_high = close_5m[0] < high_5m[0];

   // Entry prohibition conditions
   bool   ema_flat = (MathAbs(ema10_5m[0] - ema80_5m[0]) < tolerance * 5);
   bool   ema_crossing = (high_5m[0] > ema80_5m[0] && low_5m[0] < ema80_5m[0]);
   bool   end_phase_prohibited = is_end_phase;
   bool   entry_prohibited = ema_flat || ema_crossing || end_phase_prohibited;

   // Generate signals
   bool   long_signal_condition = is_long_trend_1h && (is_initial_phase || is_middle_phase) &&
                                  long_ema_setup && long_ema_position &&
                                  push_low_formed && body_above_low &&
                                  fib_touch_long && !entry_prohibited;

   bool   short_signal_condition = is_short_trend_1h && (is_initial_phase || is_middle_phase) &&
                                   short_ema_setup && short_ema_position &&
                                   return_high_formed && body_below_high &&
                                   fib_touch_short && !entry_prohibited;

   // Candle confirmation (current bar must be up candle for long, down for short)
   bool   is_up_candle = close_5m[0] > open[0];
   bool   is_down_candle = close_5m[0] < open[0];

   bool   final_long_signal = long_signal_condition && is_up_candle;
   bool   final_short_signal = short_signal_condition && is_down_candle;

   // Draw signals and lines
   if(Show_Signals)
   {
      if(final_long_signal && last_signal_bar != iBarShift(_Symbol, PERIOD_M5, Time[0]))
      {
         DrawLongSignal(Time[0], low_5m[0]);
         if(Use_Alerts) Alert("LONG SIGNAL on " + symbol_short);
         last_signal_bar = iBarShift(_Symbol, PERIOD_M5, Time[0]);
      }

      if(final_short_signal && last_signal_bar != iBarShift(_Symbol, PERIOD_M5, Time[0]))
      {
         DrawShortSignal(Time[0], high_5m[0]);
         if(Use_Alerts) Alert("SHORT SIGNAL on " + symbol_short);
         last_signal_bar = iBarShift(_Symbol, PERIOD_M5, Time[0]);
      }
   }

   if(Show_EMA)
   {
      DrawEMALines(Time[0], ema10_5m[0], ema20_5m[0], ema40_5m[0], ema80_5m[0]);
   }

   if(Show_Fib)
   {
      DrawFibonacciLevels(fib_level1_long, fib_level2_long, fib_level3_long,
                         fib_level1_short, fib_level2_short, fib_level3_short);
   }

   if(Show_Info_Panel)
   {
      DrawInfoPanel(is_long_trend_1h, is_short_trend_1h, is_flat_1h, phase_text,
                   long_ema_setup, short_ema_setup,
                   fib_touch_long, fib_touch_short,
                   push_low_formed, return_high_formed,
                   long_signal_condition, short_signal_condition,
                   !entry_prohibited);
   }

   return(rates_total);
}

//+------------------------------------------------------------------+
//| Helper Functions                                                  |
//+------------------------------------------------------------------+

void CalculateEMA(const string symbol, ENUM_TIMEFRAMES period, int ema_period, double &src[], double &out[])
{
   int handle = iMA(symbol, period, ema_period, 0, MODE_EMA, PRICE_CLOSE);
   if(handle != INVALID_HANDLE)
   {
      CopyBuffer(handle, 0, 0, ArraySize(src), out);
      IndicatorRelease(handle);
   }
}

void Analyze1HourEnvironment(double &close[], double &high[], double &low[], double &ema200[],
                             bool &is_long, bool &is_short, bool &is_flat,
                             bool &is_initial, bool &is_middle, bool &is_end, string &phase)
{
   double curr_close = close[0];
   double curr_ema200 = ema200[0];
   double tolerance = (high[0] - low[0]) * 0.5;

   // Trend direction
   is_long = curr_close > curr_ema200 && MathAbs(curr_close - curr_ema200) > tolerance;
   is_short = curr_close < curr_ema200 && MathAbs(curr_close - curr_ema200) > tolerance;
   is_flat = MathAbs(curr_close - curr_ema200) <= tolerance;

   // Phase determination
   double swing_high = GetSwingHigh(high, Lookback_Periods);
   double swing_low = GetSwingLow(low, Lookback_Periods);
   double swing_range = swing_high - swing_low;

   double level_33 = swing_low + (swing_range * 0.33);
   double level_67 = swing_low + (swing_range * 0.67);

   if(curr_close >= swing_low && curr_close <= level_33)
   {
      is_initial = true;
      is_middle = false;
      is_end = false;
      phase = "Initial";
   }
   else if(curr_close > level_33 && curr_close < level_67)
   {
      is_initial = false;
      is_middle = true;
      is_end = false;
      phase = "Middle";
   }
   else
   {
      is_initial = false;
      is_middle = false;
      is_end = true;
      phase = "End";
   }
}

void Analyze5MinuteEMA(double &ema10[], double &ema20[], double &ema40[], double &ema80[],
                       double &close[], double &high[], double &low[],
                       bool &long_setup, bool &short_setup,
                       bool &long_position, bool &short_position)
{
   double e10 = ema10[0];
   double e20 = ema20[0];
   double e40 = ema40[0];
   double e80 = ema80[0];

   double tolerance = _Point * 10;

   // Long setup: 10 > 20 > 40 > 80, all uptrending
   long_setup = (e10 > e20 && e20 > e40 && e40 > e80) &&
                ((ema10[0] - ema10[5]) > 0 && (ema20[0] - ema20[5]) > 0);

   // Short setup: 10 < 20 < 40 < 80, all downtrending
   short_setup = (e10 < e20 && e20 < e40 && e40 < e80) &&
                 ((ema10[0] - ema10[5]) < 0 && (ema20[0] - ema20[5]) < 0);

   // Position check (not crossing EMA)
   long_position = close[0] > e80 && high[0] > e80;
   short_position = close[0] < e80 && low[0] < e80;
}

double GetSwingHigh(double &high[], int lookback)
{
   double max_val = high[0];
   for(int i = 1; i < lookback && i < ArraySize(high); i++)
   {
      if(high[i] > max_val) max_val = high[i];
   }
   return max_val;
}

double GetSwingLow(double &low[], int lookback)
{
   double min_val = low[0];
   for(int i = 1; i < lookback && i < ArraySize(low); i++)
   {
      if(low[i] < min_val) min_val = low[i];
   }
   return min_val;
}

bool IsPriceNearLevel(double price, double level, double tolerance)
{
   return MathAbs(price - level) <= tolerance;
}

//+------------------------------------------------------------------+
//| Drawing Functions                                                 |
//+------------------------------------------------------------------+

void DrawLongSignal(datetime time, double price)
{
   static int signal_count = 0;
   signal_count++;
   string name = "LONG_" + IntegerToString(signal_count);

   ArrowCreate(_Symbol, time, price - _Point * 50, name, ARROW_UP, clrGreen, Arrow_Size);
}

void DrawShortSignal(datetime time, double price)
{
   static int signal_count = 0;
   signal_count++;
   string name = "SHORT_" + IntegerToString(signal_count);

   ArrowCreate(_Symbol, time, price + _Point * 50, name, ARROW_DOWN, clrRed, Arrow_Size);
}

void DrawEMALines(datetime time, double e10, double e20, double e40, double e80)
{
   // EMA lines are displayed through the indicator buffer mechanism
   // Users can add separate EMA indicators or modify this to plot
}

void DrawFibonacciLevels(double f1l, double f2l, double f3l,
                        double f1s, double f2s, double f3s)
{
   // Fibonacci levels can be displayed through manual line objects
   // This is left for the user to add if needed
}

void DrawInfoPanel(bool is_long, bool is_short, bool is_flat, string phase,
                  bool long_ema, bool short_ema,
                  bool fib_long, bool fib_short,
                  bool push_low, bool return_high,
                  bool long_ready, bool short_ready,
                  bool entry_ok)
{
   // Status output can be displayed in the chart title or as objects
   string status = symbol_short + " | ";
   status += (is_long ? "LONG" : (is_short ? "SHORT" : "FLAT")) + " | ";
   status += "Phase: " + phase + " | ";
   status += "Entry: " + (entry_ok ? "OK" : "PROHIBITED");

   Comment(status);
}

void ArrowCreate(const string symbol, const datetime time, const double price,
                const string name, int arrow_code, color clr, int size)
{
   ObjectCreate(_ChartID, name, OBJ_ARROW, 0, time, price);
   ObjectSetInteger(_ChartID, name, OBJPROP_ARROWCODE, arrow_code);
   ObjectSetInteger(_ChartID, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(_ChartID, name, OBJPROP_WIDTH, size);
}
