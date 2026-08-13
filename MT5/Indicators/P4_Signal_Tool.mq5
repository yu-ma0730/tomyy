//+------------------------------------------------------------------+
//| P4手法 - パーフェクトオーダーシグナルツール                        |
//| FX P4 Perfect Order Trend Trading Strategy for MT5                |
//+------------------------------------------------------------------+
#property copyright "P4 Trading System"
#property link      "https://fx-trading-p4.local"
#property version   "2.00"
#property description "P4手法 - ボリンジャーバンド＆シグナル表示ツール"
#property strict
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   5

// BB buffers
#property indicator_label1  "BB Upper"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGray
#property indicator_width1  1
#property indicator_style1  STYLE_DOT

#property indicator_label2  "BB Lower"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGray
#property indicator_width2  1
#property indicator_style2  STYLE_DOT

#property indicator_label3  "BB Middle"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrGray
#property indicator_width3  1

// Signal buffers
#property indicator_label4  "Long Entry"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrLime
#property indicator_width4  2

#property indicator_label5  "Short Entry"
#property indicator_type5   DRAW_ARROW
#property indicator_color5  clrRed
#property indicator_width5  2

// Buffers
double bb_upper_buf[], bb_lower_buf[], bb_middle_buf[];
double long_entry_buf[], short_entry_buf[];

// Input parameters
input int BB_Period = 20;
input double BB_Deviation = 2.0;
input int Lookback_Bars = 5;
input bool Use_BB_Filter = true;

// Global variables
int bb_handle;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   // Set buffer pointers and labels
   SetIndexBuffer(0, bb_upper_buf, INDICATOR_DATA);
   SetIndexBuffer(1, bb_lower_buf, INDICATOR_DATA);
   SetIndexBuffer(2, bb_middle_buf, INDICATOR_DATA);
   SetIndexBuffer(3, long_entry_buf, INDICATOR_DATA);
   SetIndexBuffer(4, short_entry_buf, INDICATOR_DATA);

   // Create handle for Bollinger Bands
   bb_handle = iBands(_Symbol, _Period, BB_Period, 0, BB_Deviation, PRICE_CLOSE);

   if(bb_handle == INVALID_HANDLE)
   {
      Print("Error creating Bollinger Bands handle");
      return INIT_FAILED;
   }

   // Set indicator to 15M only
   if(_Period != PERIOD_M15)
   {
      Alert("このインジケーターは15分足専用です。現在の時間足: ",
            EnumToString(_Period));
      return INIT_FAILED;
   }

   IndicatorSetString(INDICATOR_SHORTNAME, "P4手法 シグナル");
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);

   // Set chart name to avoid confusion
   ChartSetString(0, CHART_COMMENT, "P4手法 パーフェクトオーダー");

   return INIT_SUCCEEDED;
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
   if(rates_total < 100)
      return 0;

   // Copy Bollinger Bands values
   if(CopyBuffer(bb_handle, 1, 0, rates_total, bb_upper_buf) <= 0)
      return 0;
   if(CopyBuffer(bb_handle, 2, 0, rates_total, bb_lower_buf) <= 0)
      return 0;
   if(CopyBuffer(bb_handle, 0, 0, rates_total, bb_middle_buf) <= 0)
      return 0;

   int start = prev_calculated > 0 ? prev_calculated - 1 : Lookback_Bars + 1;

   // Display legend on first calculation
   if(prev_calculated == 0)
   {
      DisplayLegend();
   }

   for(int i = start; i < rates_total; i++)
   {
      long_entry_buf[i] = EMPTY_VALUE;
      short_entry_buf[i] = EMPTY_VALUE;

      // Check for potential long entry (price near lower BB)
      if(CheckLongSignal(i, close, high, low))
      {
         long_entry_buf[i] = low[i] - 0.0002 * _Point;
      }

      // Check for potential short entry (price near upper BB)
      if(CheckShortSignal(i, close, high, low))
      {
         short_entry_buf[i] = high[i] + 0.0002 * _Point;
      }
   }

   return rates_total;
}

//+------------------------------------------------------------------+
//| Display Legend                                                   |
//+------------------------------------------------------------------+
void DisplayLegend()
{
   // Create legend text
   string legend_text = "P4手法 シグナルツール\n";
   legend_text += "15分足専用 - EMA別途追加が必要\n";
   legend_text += "BB=ボリンジャーバンド\n";
   legend_text += "緑矢印=ロングシグナル  赤矢印=ショートシグナル";

   // Remove old label if exists
   ObjectDelete(0, "P4_Legend");

   // Create text label
   ObjectCreate(0, "P4_Legend", OBJ_LABEL, 0, 0, 0);
   ObjectSetString(0, "P4_Legend", OBJPROP_TEXT, legend_text);
   ObjectSetInteger(0, "P4_Legend", OBJPROP_XDISTANCE, 10);
   ObjectSetInteger(0, "P4_Legend", OBJPROP_YDISTANCE, 30);
   ObjectSetInteger(0, "P4_Legend", OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, "P4_Legend", OBJPROP_FONTSIZE, 9);
   ObjectSetString(0, "P4_Legend", OBJPROP_FONT, "Arial");
   ObjectSetInteger(0, "P4_Legend", OBJPROP_COLOR, clrWhiteSmoke);
   ObjectSetInteger(0, "P4_Legend", OBJPROP_BACK, false);
   ObjectSetInteger(0, "P4_Legend", OBJPROP_SELECTABLE, false);
}

//+------------------------------------------------------------------+
//| Check Long Signal                                                |
//+------------------------------------------------------------------+
bool CheckLongSignal(int bar, const double &close[], const double &high[], const double &low[])
{
   if(bar < 2)
      return false;

   // Check if price breaks above recent resistance (wick high)
   double wick_high = high[bar];
   for(int i = 1; i <= Lookback_Bars && bar-i >= 0; i++)
   {
      if(high[bar-i] > wick_high)
         wick_high = high[bar-i];
   }

   // Entry signal when price breaks above wick
   if(close[bar] > wick_high && close[bar-1] <= wick_high)
   {
      // BB Filter: avoid entry if price is far outside BB
      if(Use_BB_Filter)
      {
         if(close[bar] > bb_upper_buf[bar])
            return false; // Price too far above BB
      }
      return true;
   }

   return false;
}

//+------------------------------------------------------------------+
//| Check Short Signal                                               |
//+------------------------------------------------------------------+
bool CheckShortSignal(int bar, const double &close[], const double &high[], const double &low[])
{
   if(bar < 2)
      return false;

   // Check if price breaks below recent support (wick low)
   double wick_low = low[bar];
   for(int i = 1; i <= Lookback_Bars && bar-i >= 0; i++)
   {
      if(low[bar-i] < wick_low)
         wick_low = low[bar-i];
   }

   // Entry signal when price breaks below wick
   if(close[bar] < wick_low && close[bar-1] >= wick_low)
   {
      // BB Filter: avoid entry if price is far outside BB
      if(Use_BB_Filter)
      {
         if(close[bar] < bb_lower_buf[bar])
            return false; // Price too far below BB
      }
      return true;
   }

   return false;
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   ReleaseBufHandle(bb_handle);

   // Remove legend on deinitialization
   ObjectDelete(0, "P4_Legend");
}

//+------------------------------------------------------------------+
//| Release Indicator Handle                                         |
//+------------------------------------------------------------------+
void ReleaseBufHandle(int handle)
{
   if(handle != INVALID_HANDLE)
      IndicatorRelease(handle);
}
