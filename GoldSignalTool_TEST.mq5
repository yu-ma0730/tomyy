//+------------------------------------------------------------------+
//| Simple Test Indicator for Gold Signal
//+------------------------------------------------------------------+
#property copyright "Gold Trading Test"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBlue
#property indicator_width1  2

double TestBuffer[];

int OnInit()
{
   SetIndexBuffer(0, TestBuffer, INDICATOR_DATA);
   IndicatorSetString(INDICATOR_SHORTNAME, "Gold_TEST");
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
   for(int i = prev_calculated - 1; i < rates_total; i++)
   {
      TestBuffer[i] = close[i];  // 終値をそのまま表示
   }
   return rates_total;
}
