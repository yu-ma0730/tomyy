//+------------------------------------------------------------------+
//| Gold 5min Trading Signal Tool - LINE VERSION
//| Simplified with line-based signal display
//+------------------------------------------------------------------+
#property copyright "Gold Trading"
#property version   "2.01"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2
#property indicator_type1   DRAW_LINE
#property indicator_type2   DRAW_LINE
#property indicator_color1  clrGreen
#property indicator_color2  clrRed
#property indicator_width1  3
#property indicator_width2  3
#property indicator_label1  "Buy Signal"
#property indicator_label2  "Sell Signal"

double BuySignal[];
double SellSignal[];

input int EMA_20 = 20;
input int EMA_80 = 80;
input int EMA_200 = 200;

int OnInit()
{
   SetIndexBuffer(0, BuySignal, INDICATOR_DATA);
   SetIndexBuffer(1, SellSignal, INDICATOR_DATA);

   IndicatorSetInteger(INDICATOR_DIGITS, 2);

   ArrayInitialize(BuySignal, 0);
   ArrayInitialize(SellSignal, 0);

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
   if(rates_total < EMA_200 + 10)
      return rates_total;

   int start = 0;
   if(prev_calculated > 0)
      start = prev_calculated - 1;

   for(int i = start; i < rates_total; i++)
   {
      BuySignal[i] = 0;
      SellSignal[i] = 0;

      if(i < 2)
         continue;

      double ema20 = iMA(Symbol(), PERIOD_M5, EMA_20, 0, MODE_EMA, i);
      double ema80 = iMA(Symbol(), PERIOD_M5, EMA_80, 0, MODE_EMA, i);
      double ema200 = iMA(Symbol(), PERIOD_M5, EMA_200, 0, MODE_EMA, i);

      double c = close[i];
      double l = low[i];
      double h = high[i];

      if(c > 0 && ema20 > 0 && ema80 > 0 && ema200 > 0)
      {
         if(c > ema200 && ema20 > ema80 && ema80 > ema200)
         {
            if(l < ema20 && l > ema20 - 50 * Point())
            {
               BuySignal[i] = close[i];
            }
         }

         if(c < ema200 && ema20 < ema80 && ema80 < ema200)
         {
            if(h > ema20 && h < ema20 + 50 * Point())
            {
               SellSignal[i] = close[i];
            }
         }
      }
   }

   return rates_total;
}
