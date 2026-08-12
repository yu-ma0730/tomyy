//+------------------------------------------------------------------+
//| P4 Signal Tool for MT5                                           |
//| FX P4 Perfect Order Trend Trading Strategy                       |
//+------------------------------------------------------------------+
#property copyright "P4 Trading System"
#property link      "https://fx-trading-p4.local"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 10
#property indicator_plots   10

// EMA buffers
#property indicator_label1  "EMA(10)"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_width1  2

#property indicator_label2  "EMA(20)"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrOrange
#property indicator_width2  2

#property indicator_label3  "EMA(40)"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrGreen
#property indicator_width3  2

#property indicator_label4  "EMA(80)"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrBlue
#property indicator_width4  2

// BB buffers
#property indicator_label5  "BB Upper"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrGray
#property indicator_width5  1
#property indicator_style5  STYLE_DOT

#property indicator_label6  "BB Lower"
#property indicator_type6   DRAW_LINE
#property indicator_color6  clrGray
#property indicator_width6  1
#property indicator_style6  STYLE_DOT

#property indicator_label7  "BB Middle"
#property indicator_type7   DRAW_LINE
#property indicator_color7  clrGray
#property indicator_width7  1

// Signal buffers
#property indicator_label8  "Long Entry"
#property indicator_type8   DRAW_ARROW
#property indicator_color8  clrLime
#property indicator_width8  2

#property indicator_label9  "Short Entry"
#property indicator_type9   DRAW_ARROW
#property indicator_color9  clrRed
#property indicator_width9  2

#property indicator_label10 "Perfect Order"
#property indicator_type10  DRAW_HISTOGRAM
#property indicator_color10 clrLightBlue
#property indicator_width10 1

// Buffers
double ema10_buf[], ema20_buf[], ema40_buf[], ema80_buf[];
double bb_upper_buf[], bb_lower_buf[], bb_middle_buf[];
double long_entry_buf[], short_entry_buf[], po_buf[];

// Input parameters
input int EMA10_Period = 10;
input int EMA20_Period = 20;
input int EMA40_Period = 40;
input int EMA80_Period = 80;
input int BB_Period = 20;
input double BB_Deviation = 2.0;
input int Lookback_Bars = 5;
input bool Show_PerfectOrder_Info = true;
input bool Use_BB_Filter = true;

// Global variables
int ema10_handle, ema20_handle, ema40_handle, ema80_handle;
int bb_handle;
bool po_long_active = false;
bool po_short_active = false;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   // Set buffer pointers and labels
   SetIndexBuffer(0, ema10_buf, INDICATOR_DATA);
   SetIndexBuffer(1, ema20_buf, INDICATOR_DATA);
   SetIndexBuffer(2, ema40_buf, INDICATOR_DATA);
   SetIndexBuffer(3, ema80_buf, INDICATOR_DATA);
   SetIndexBuffer(4, bb_upper_buf, INDICATOR_DATA);
   SetIndexBuffer(5, bb_lower_buf, INDICATOR_DATA);
   SetIndexBuffer(6, bb_middle_buf, INDICATOR_DATA);
   SetIndexBuffer(7, long_entry_buf, INDICATOR_DATA);
   SetIndexBuffer(8, short_entry_buf, INDICATOR_DATA);
   SetIndexBuffer(9, po_buf, INDICATOR_DATA);

   // Create handles for technical indicators
   ema10_handle = iMA(_Symbol, _Period, EMA10_Period, 0, MODE_EMA, PRICE_CLOSE);
   ema20_handle = iMA(_Symbol, _Period, EMA20_Period, 0, MODE_EMA, PRICE_CLOSE);
   ema40_handle = iMA(_Symbol, _Period, EMA40_Period, 0, MODE_EMA, PRICE_CLOSE);
   ema80_handle = iMA(_Symbol, _Period, EMA80_Period, 0, MODE_EMA, PRICE_CLOSE);
   bb_handle = iBands(_Symbol, _Period, BB_Period, 0, BB_Deviation, PRICE_CLOSE);

   if(ema10_handle == INVALID_HANDLE || ema20_handle == INVALID_HANDLE ||
      ema40_handle == INVALID_HANDLE || ema80_handle == INVALID_HANDLE ||
      bb_handle == INVALID_HANDLE)
   {
      Print("Error creating indicator handles");
      return INIT_FAILED;
   }

   // Set indicator to 15M only
   if(_Period != PERIOD_M15)
   {
      Alert("This indicator works only on 15-minute timeframe. Current timeframe: ",
            EnumToString(_Period));
      return INIT_FAILED;
   }

   IndicatorSetString(INDICATOR_SHORTNAME, "P4 Signal Tool - EMA(10,20,40,80) (15M)");
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);

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

   // Copy indicator values
   if(CopyBuffer(ema10_handle, 0, 0, rates_total, ema10_buf) <= 0)
      return 0;
   if(CopyBuffer(ema20_handle, 0, 0, rates_total, ema20_buf) <= 0)
      return 0;
   if(CopyBuffer(ema40_handle, 0, 0, rates_total, ema40_buf) <= 0)
      return 0;
   if(CopyBuffer(ema80_handle, 0, 0, rates_total, ema80_buf) <= 0)
      return 0;
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
      // Check Perfect Order conditions
      po_buf[i] = 0;
      long_entry_buf[i] = EMPTY_VALUE;
      short_entry_buf[i] = EMPTY_VALUE;

      // Perfect Order Long: EMA10 > EMA20 > EMA40 > EMA80
      if(ema10_buf[i] > ema20_buf[i] &&
         ema20_buf[i] > ema40_buf[i] &&
         ema40_buf[i] > ema80_buf[i])
      {
         po_long_active = true;
         po_buf[i] = 1;

         // Check for entry signal
         if(CheckLongEntry(i, close, high, low))
         {
            long_entry_buf[i] = low[i] - 0.0002 * _Point;
         }
      }
      else
      {
         po_long_active = false;
      }

      // Perfect Order Short: EMA80 > EMA40 > EMA20 > EMA10
      if(ema80_buf[i] > ema40_buf[i] &&
         ema40_buf[i] > ema20_buf[i] &&
         ema20_buf[i] > ema10_buf[i])
      {
         po_short_active = true;
         po_buf[i] = -1;

         // Check for entry signal
         if(CheckShortEntry(i, close, high, low))
         {
            short_entry_buf[i] = high[i] + 0.0002 * _Point;
         }
      }
      else
      {
         po_short_active = false;
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
   string legend_text = "P4 Signal Tool - EMA(10,20,40,80)\n";
   legend_text += "Red=EMA10  Orange=EMA20  Green=EMA40  Blue=EMA80\n";
   legend_text += "BB=Bollinger Band  Green Arrow=Long  Red Arrow=Short";

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
//| Check Long Entry Signal                                          |
//+------------------------------------------------------------------+
bool CheckLongEntry(int bar, const double &close[], const double &high[], const double &low[])
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

   // Entry when price breaks above wick
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
//| Check Short Entry Signal                                         |
//+------------------------------------------------------------------+
bool CheckShortEntry(int bar, const double &close[], const double &high[], const double &low[])
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

   // Entry when price breaks below wick
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
   ReleaseBufHandle(ema10_handle);
   ReleaseBufHandle(ema20_handle);
   ReleaseBufHandle(ema40_handle);
   ReleaseBufHandle(ema80_handle);
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
