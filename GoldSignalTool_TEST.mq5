//+------------------------------------------------------------------+
//| Simple Test Indicator for Gold Signal - Diagnostic Version
//+------------------------------------------------------------------+
#property copyright "Gold Trading Test"
#property version   "1.01"
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBlue
#property indicator_width1  2
#property indicator_label1  "Close Price"

double TestBuffer[];

int OnInit()
{
   SetIndexBuffer(0, TestBuffer, INDICATOR_DATA);
   IndicatorSetString(INDICATOR_SHORTNAME, "Gold_TEST_v1");
   ArrayInitialize(TestBuffer, 0);
   return(INIT_SUCCEEDED);
}

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
   int start = 0;
   if(prev_calculated > 0)
      start = prev_calculated - 1;

   for(int i = start; i < rates_total; i++)
   {
      TestBuffer[i] = close[i];
   }

   return rates_total;
}
