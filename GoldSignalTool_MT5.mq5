//+------------------------------------------------------------------+
//| Gold 5min Trading Signal Tool - MT5
//| Based on 1H observation + 5M entry rules
//+------------------------------------------------------------------+
#property copyright "Gold Trading"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2
#property indicator_type1   DRAW_ARROW
#property indicator_type2   DRAW_ARROW

//--- Plot properties
#property indicator_color1  clrGreen
#property indicator_color2  clrRed
#property indicator_width1  2
#property indicator_width2  2

//--- Buffers
double BuySignal[];
double SellSignal[];

//--- Input parameters
input int EMA_20 = 20;
input int EMA_80 = 80;
input int EMA_200 = 200;
input int HistoryBars = 500;
input bool EnableAlert = true;
input bool EnableSound = true;

//--- Global variables
int lastBuyBar = -1;
int lastSellBar = -1;

//+------------------------------------------------------------------+
//| Custom indicator initialization function
//+------------------------------------------------------------------+
int OnInit()
{
   //--- Allocate memory for buffers
   SetIndexBuffer(0, BuySignal, INDICATOR_DATA);
   SetIndexBuffer(1, SellSignal, INDICATOR_DATA);

   //--- Set indicator digits
   IndicatorSetInteger(INDICATOR_DIGITS, 2);

   //--- Arrow codes
   PlotIndexSetInteger(0, PLOT_ARROW, 241); // Up arrow
   PlotIndexSetInteger(1, PLOT_ARROW, 242); // Down arrow

   //--- Initialize
   ArrayInitialize(BuySignal, 0);
   ArrayInitialize(SellSignal, 0);

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Main calculation function
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
   if(rates_total < EMA_200 + 10) return rates_total;

   int start = prev_calculated > 0 ? prev_calculated - 1 : 0;

   for(int i = start; i < rates_total; i++)
   {
      BuySignal[i] = 0;
      SellSignal[i] = 0;

      // Check for buy signal (5M M5)
      if(CheckBuySignal(i))
      {
         BuySignal[i] = low[i] - 50 * Point();
         if(i > lastBuyBar)
         {
            lastBuyBar = i;
            if(EnableAlert)
            {
               AlertSignal("BUY", Symbol(), time[i]);
            }
         }
      }

      // Check for sell signal (5M M5)
      if(CheckSellSignal(i))
      {
         SellSignal[i] = high[i] + 50 * Point();
         if(i > lastSellBar)
         {
            lastSellBar = i;
            if(EnableAlert)
            {
               AlertSignal("SELL", Symbol(), time[i]);
            }
         }
      }
   }

   return rates_total;
}

//+------------------------------------------------------------------+
//| Check BUY Signal Conditions
//+------------------------------------------------------------------+
bool CheckBuySignal(int bar)
{
   // Get 1H timeframe data (H1)
   double h1_ema20 = iMA(Symbol(), PERIOD_H1, EMA_20, 0, MODE_EMA, bar);
   double h1_ema80 = iMA(Symbol(), PERIOD_H1, EMA_80, 0, MODE_EMA, bar);
   double h1_ema200 = iMA(Symbol(), PERIOD_H1, EMA_200, 0, MODE_EMA, bar);

   double h1_close = iClose(Symbol(), PERIOD_H1, bar);
   double h1_open = iOpen(Symbol(), PERIOD_H1, bar);
   double h1_high = iHigh(Symbol(), PERIOD_H1, bar);
   double h1_low = iLow(Symbol(), PERIOD_H1, bar);

   // Get M5 (5min) data
   double m5_close = iClose(Symbol(), PERIOD_M5, bar);
   double m5_open = iOpen(Symbol(), PERIOD_M5, bar);
   double m5_high = iHigh(Symbol(), PERIOD_M5, bar);
   double m5_low = iLow(Symbol(), PERIOD_M5, bar);

   double m5_ema20 = iMA(Symbol(), PERIOD_M5, EMA_20, 0, MODE_EMA, bar);
   double m5_ema80 = iMA(Symbol(), PERIOD_M5, EMA_80, 0, MODE_EMA, bar);
   double m5_ema200 = iMA(Symbol(), PERIOD_M5, EMA_200, 0, MODE_EMA, bar);

   //--- 1. Environment check (1H)
   // Price must be above 200 EMA
   if(h1_close <= h1_ema200)
      return false;

   // 1H must be calm (EMA aligned)
   if(!IsH1Calm(bar))
      return false;

   //--- 2. Check for push-low formation (M5)
   // Need at least 2 consecutive M5 bars forming a low
   if(!CheckPushLowFormation(bar))
      return false;

   //--- 3. Support check (M5 EMA)
   // M5 low must be supported by EMA20 or EMA80
   if(m5_low >= m5_ema20 - 20 * Point() && m5_low <= m5_ema20 + 20 * Point())
      return true;

   if(m5_low >= m5_ema80 - 20 * Point() && m5_low <= m5_ema80 + 20 * Point())
      return true;

   return false;
}

//+------------------------------------------------------------------+
//| Check SELL Signal Conditions
//+------------------------------------------------------------------+
bool CheckSellSignal(int bar)
{
   // Get 1H timeframe data
   double h1_ema20 = iMA(Symbol(), PERIOD_H1, EMA_20, 0, MODE_EMA, bar);
   double h1_ema80 = iMA(Symbol(), PERIOD_H1, EMA_80, 0, MODE_EMA, bar);
   double h1_ema200 = iMA(Symbol(), PERIOD_H1, EMA_200, 0, MODE_EMA, bar);

   double h1_close = iClose(Symbol(), PERIOD_H1, bar);
   double h1_open = iOpen(Symbol(), PERIOD_H1, bar);
   double h1_high = iHigh(Symbol(), PERIOD_H1, bar);
   double h1_low = iLow(Symbol(), PERIOD_H1, bar);

   // Get M5 (5min) data
   double m5_close = iClose(Symbol(), PERIOD_M5, bar);
   double m5_open = iOpen(Symbol(), PERIOD_M5, bar);
   double m5_high = iHigh(Symbol(), PERIOD_M5, bar);
   double m5_low = iLow(Symbol(), PERIOD_M5, bar);

   double m5_ema20 = iMA(Symbol(), PERIOD_M5, EMA_20, 0, MODE_EMA, bar);
   double m5_ema80 = iMA(Symbol(), PERIOD_M5, EMA_80, 0, MODE_EMA, bar);
   double m5_ema200 = iMA(Symbol(), PERIOD_M5, EMA_200, 0, MODE_EMA, bar);

   //--- 1. Environment check (1H)
   // Price must be below 200 EMA
   if(h1_close >= h1_ema200)
      return false;

   // 1H must be calm
   if(!IsH1Calm(bar))
      return false;

   //--- 2. Check for retracement-high formation (M5)
   if(!CheckRetracementHighFormation(bar))
      return false;

   //--- 3. Resistance check (M5 EMA)
   // M5 high must be resisted by EMA20 or EMA80
   if(m5_high >= m5_ema20 - 20 * Point() && m5_high <= m5_ema20 + 20 * Point())
      return true;

   if(m5_high >= m5_ema80 - 20 * Point() && m5_high <= m5_ema80 + 20 * Point())
      return true;

   return false;
}

//+------------------------------------------------------------------+
//| Check if 1H is calm (no volatile phase)
//+------------------------------------------------------------------+
bool IsH1Calm(int bar)
{
   // Check last 3 H1 bars for calmness
   for(int i = bar; i < bar + 3 && i < iBars(Symbol(), PERIOD_H1); i++)
   {
      double h1_open = iOpen(Symbol(), PERIOD_H1, i);
      double h1_close = iClose(Symbol(), PERIOD_H1, i);
      double h1_high = iHigh(Symbol(), PERIOD_H1, i);
      double h1_low = iLow(Symbol(), PERIOD_H1, i);

      double body = MathAbs(h1_close - h1_open);
      double wick = MathMax(h1_high - MathMax(h1_open, h1_close),
                            MathMin(h1_open, h1_close) - h1_low);

      // Reject if wick is too long (>2x body)
      if(wick > body * 2.0)
         return false;

      // Reject if bar is too large (>50 pips)
      if((h1_high - h1_low) > 50 * Point())
         return false;
   }

   // Check that H1 EMA is stable (not crossing)
   double h1_ema20_0 = iMA(Symbol(), PERIOD_H1, EMA_20, 0, MODE_EMA, bar);
   double h1_ema20_1 = iMA(Symbol(), PERIOD_H1, EMA_20, 0, MODE_EMA, bar + 1);
   double h1_ema80_0 = iMA(Symbol(), PERIOD_H1, EMA_80, 0, MODE_EMA, bar);
   double h1_ema80_1 = iMA(Symbol(), PERIOD_H1, EMA_80, 0, MODE_EMA, bar + 1);
   double h1_ema200_0 = iMA(Symbol(), PERIOD_H1, EMA_200, 0, MODE_EMA, bar);
   double h1_ema200_1 = iMA(Symbol(), PERIOD_H1, EMA_200, 0, MODE_EMA, bar + 1);

   // Reject if multiple EMA crossings
   int crossing_count = 0;
   if((h1_ema20_0 > h1_ema80_0) != (h1_ema20_1 > h1_ema80_1)) crossing_count++;
   if((h1_ema80_0 > h1_ema200_0) != (h1_ema80_1 > h1_ema200_1)) crossing_count++;
   if((h1_ema20_0 > h1_ema200_0) != (h1_ema20_1 > h1_ema200_1)) crossing_count++;

   return crossing_count == 0;
}

//+------------------------------------------------------------------+
//| Check push-low formation (2+ M5 bars)
//+------------------------------------------------------------------+
bool CheckPushLowFormation(int bar)
{
   double m5_low_0 = iLow(Symbol(), PERIOD_M5, bar);
   double m5_low_1 = iLow(Symbol(), PERIOD_M5, bar + 1);
   double m5_low_2 = iLow(Symbol(), PERIOD_M5, bar + 2);

   double m5_ema200 = iMA(Symbol(), PERIOD_M5, EMA_200, 0, MODE_EMA, bar);

   // Need at least 2 bars with similar lows (within 30 pips)
   if(MathAbs(m5_low_0 - m5_low_1) < 30 * Point())
   {
      // Must not break 200 EMA
      if(m5_low_0 >= m5_ema200 && m5_low_1 >= m5_ema200)
         return true;
   }

   if(MathAbs(m5_low_1 - m5_low_2) < 30 * Point())
   {
      if(m5_low_1 >= m5_ema200 && m5_low_2 >= m5_ema200)
         return true;
   }

   return false;
}

//+------------------------------------------------------------------+
//| Check retracement-high formation (2+ M5 bars)
//+------------------------------------------------------------------+
bool CheckRetracementHighFormation(int bar)
{
   double m5_high_0 = iHigh(Symbol(), PERIOD_M5, bar);
   double m5_high_1 = iHigh(Symbol(), PERIOD_M5, bar + 1);
   double m5_high_2 = iHigh(Symbol(), PERIOD_M5, bar + 2);

   double m5_ema200 = iMA(Symbol(), PERIOD_M5, EMA_200, 0, MODE_EMA, bar);

   // Need at least 2 bars with similar highs (within 30 pips)
   if(MathAbs(m5_high_0 - m5_high_1) < 30 * Point())
   {
      // Must not break 200 EMA
      if(m5_high_0 <= m5_ema200 && m5_high_1 <= m5_ema200)
         return true;
   }

   if(MathAbs(m5_high_1 - m5_high_2) < 30 * Point())
   {
      if(m5_high_1 <= m5_ema200 && m5_high_2 <= m5_ema200)
         return true;
   }

   return false;
}

//+------------------------------------------------------------------+
//| Alert Signal
//+------------------------------------------------------------------+
void AlertSignal(string type, string symbol, datetime time)
{
   string msg = type + " Signal - " + symbol + " at " + TimeToString(time);

   if(EnableAlert)
   {
      Alert(msg);
   }

   if(EnableSound)
   {
      PlaySound("alert.wav");
   }

   // Print to journal
   Print(msg);
}

//+------------------------------------------------------------------+
//| OnDeinit
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   Print("Signal Tool Stopped");
}
