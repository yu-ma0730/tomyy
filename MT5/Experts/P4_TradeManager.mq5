//+------------------------------------------------------------------+
//| P4 Trade Manager EA for MT5                                      |
//| Automated P4 Perfect Order Trading System                        |
//+------------------------------------------------------------------+
#property copyright "P4 Trading System"
#property link      "https://fx-trading-p4.local"
#property version   "1.00"
#property strict

//--- Input parameters
input int Magic = 12345;
input double LotSize = 0.1;
input int EntryLookback = 5;
input bool AutoTrading = false;
input double RiskPercent = 1.0;
input double RiskRewardRatio = 1.0;
input bool Use_BB_Filter = true;
input bool Extend_Profit_on_N_Pattern = true;
input bool Use_EMA80_Touch = false;

// EMA parameters
input int EMA10_Period = 10;
input int EMA20_Period = 20;
input int EMA40_Period = 40;
input int EMA80_Period = 80;

// BB parameters
input int BB_Period = 20;
input double BB_Deviation = 2.0;

// Trade state
struct TradeState {
   bool long_active;
   bool short_active;
   double entry_price;
   double stop_loss;
   double take_profit;
   datetime entry_time;
   int wick_bars;
   double wick_resistance;
   double wick_support;
};

TradeState trade_state;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   // Initialize trade state
   trade_state.long_active = false;
   trade_state.short_active = false;

   // Check timeframe
   if(_Period != PERIOD_M15)
   {
      Alert("This EA works only on 15-minute timeframe");
      return INIT_FAILED;
   }

   Print("P4 Trade Manager initialized. AutoTrading: ", AutoTrading);
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   Print("P4 Trade Manager deinitialized. Reason: ", reason);
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   static datetime last_bar_time = 0;
   datetime current_bar_time = iTime(_Symbol, _Period, 0);

   // Process only on new bar
   if(current_bar_time == last_bar_time)
      return;

   last_bar_time = current_bar_time;

   // Get current data
   MqlRates rates[];
   if(CopyRates(_Symbol, _Period, 0, 100, rates) <= 0)
      return;

   ArraySetAsSeries(rates, true);

   // Get indicator values
   double ema10[], ema20[], ema40[], ema80[];
   if(!GetEMA(ema10, EMA10_Period) || !GetEMA(ema20, EMA20_Period) ||
      !GetEMA(ema40, EMA40_Period) || !GetEMA(ema80, EMA80_Period))
      return;

   double bb_upper[], bb_lower[], bb_middle[];
   if(!GetBollingerBands(bb_upper, bb_lower, bb_middle))
      return;

   // Check Perfect Order conditions
   bool po_long = (ema10[0] > ema20[0] && ema20[0] > ema40[0] && ema40[0] > ema80[0]);
   bool po_short = (ema80[0] > ema40[0] && ema40[0] > ema20[0] && ema20[0] > ema10[0]);
   bool po_broken = (!po_long && !po_short);

   // Force close on Perfect Order break
   if(po_broken)
   {
      CloseAllOrders();
      trade_state.long_active = false;
      trade_state.short_active = false;
      return;
   }

   // Check for entry signals
   if(po_long && !trade_state.long_active)
   {
      if(CheckLongEntry(rates, ema10, ema20, ema40, ema80, bb_upper, bb_lower))
      {
         if(AutoTrading)
            OpenLongPosition(rates);
      }
   }

   if(po_short && !trade_state.short_active)
   {
      if(CheckShortEntry(rates, ema10, ema20, ema40, ema80, bb_upper, bb_lower))
      {
         if(AutoTrading)
            OpenShortPosition(rates);
      }
   }

   // Update stop loss and take profit
   UpdateTradeState(rates, ema80);

   // Check profit extension on N pattern
   if(Extend_Profit_on_N_Pattern)
   {
      ExtendProfitOnNPattern(rates);
   }

   // Check EMA80 touch for profit extension
   if(Use_EMA80_Touch)
   {
      CheckEMA80Touch(rates, ema80);
   }
}

//+------------------------------------------------------------------+
//| Get EMA values                                                   |
//+------------------------------------------------------------------+
bool GetEMA(double &buffer[], int period)
{
   int handle = iMA(_Symbol, _Period, period, 0, MODE_EMA, PRICE_CLOSE);
   if(handle == INVALID_HANDLE)
      return false;

   if(CopyBuffer(handle, 0, 0, 100, buffer) <= 0)
   {
      IndicatorRelease(handle);
      return false;
   }

   ArraySetAsSeries(buffer, true);
   IndicatorRelease(handle);
   return true;
}

//+------------------------------------------------------------------+
//| Get Bollinger Bands values                                       |
//+------------------------------------------------------------------+
bool GetBollingerBands(double &upper[], double &lower[], double &middle[])
{
   int handle = iBands(_Symbol, _Period, BB_Period, 0, BB_Deviation, PRICE_CLOSE);
   if(handle == INVALID_HANDLE)
      return false;

   if(CopyBuffer(handle, 1, 0, 100, upper) <= 0 ||
      CopyBuffer(handle, 2, 0, 100, lower) <= 0 ||
      CopyBuffer(handle, 0, 0, 100, middle) <= 0)
   {
      IndicatorRelease(handle);
      return false;
   }

   ArraySetAsSeries(upper, true);
   ArraySetAsSeries(lower, true);
   ArraySetAsSeries(middle, true);
   IndicatorRelease(handle);
   return true;
}

//+------------------------------------------------------------------+
//| Check Long Entry Signal                                          |
//+------------------------------------------------------------------+
bool CheckLongEntry(const MqlRates &rates[], const double &ema10[],
                    const double &ema20[], const double &ema40[],
                    const double &ema80[], const double &bb_upper[],
                    const double &bb_lower[])
{
   // Find wick resistance
   double wick_high = rates[0].high;
   for(int i = 1; i <= EntryLookback; i++)
      if(rates[i].high > wick_high)
         wick_high = rates[i].high;

   // Entry condition: break above wick
   if(rates[0].close > wick_high)
   {
      // BB Filter
      if(Use_BB_Filter && rates[0].close > bb_upper[0])
         return false;

      trade_state.wick_resistance = wick_high;
      return true;
   }

   return false;
}

//+------------------------------------------------------------------+
//| Check Short Entry Signal                                         |
//+------------------------------------------------------------------+
bool CheckShortEntry(const MqlRates &rates[], const double &ema10[],
                     const double &ema20[], const double &ema40[],
                     const double &ema80[], const double &bb_upper[],
                     const double &bb_lower[])
{
   // Find wick support
   double wick_low = rates[0].low;
   for(int i = 1; i <= EntryLookback; i++)
      if(rates[i].low < wick_low)
         wick_low = rates[i].low;

   // Entry condition: break below wick
   if(rates[0].close < wick_low)
   {
      // BB Filter
      if(Use_BB_Filter && rates[0].close < bb_lower[0])
         return false;

      trade_state.wick_support = wick_low;
      return true;
   }

   return false;
}

//+------------------------------------------------------------------+
//| Open Long Position                                               |
//+------------------------------------------------------------------+
void OpenLongPosition(const MqlRates &rates[])
{
   double entry = rates[0].close;
   double stop_loss = GetLongStopLoss(rates);
   double risk = entry - stop_loss;
   double take_profit = entry + (risk * RiskRewardRatio);

   MqlTradeRequest request = {};
   MqlTradeResult result = {};

   request.action = TRADE_ACTION_BUY;
   request.symbol = _Symbol;
   request.volume = LotSize;
   request.price = entry;
   request.sl = stop_loss;
   request.tp = take_profit;
   request.magic = Magic;
   request.comment = "P4 Long Entry";

   if(OrderSend(request, result))
   {
      trade_state.long_active = true;
      trade_state.entry_price = entry;
      trade_state.stop_loss = stop_loss;
      trade_state.take_profit = take_profit;
      trade_state.entry_time = TimeCurrent();

      Print("Long position opened. Entry: ", entry, " SL: ", stop_loss, " TP: ", take_profit);
   }
   else
   {
      Print("Failed to open long position. Error: ", result.retcode);
   }
}

//+------------------------------------------------------------------+
//| Open Short Position                                              |
//+------------------------------------------------------------------+
void OpenShortPosition(const MqlRates &rates[])
{
   double entry = rates[0].close;
   double stop_loss = GetShortStopLoss(rates);
   double risk = stop_loss - entry;
   double take_profit = entry - (risk * RiskRewardRatio);

   MqlTradeRequest request = {};
   MqlTradeResult result = {};

   request.action = TRADE_ACTION_SELL;
   request.symbol = _Symbol;
   request.volume = LotSize;
   request.price = entry;
   request.sl = stop_loss;
   request.tp = take_profit;
   request.magic = Magic;
   request.comment = "P4 Short Entry";

   if(OrderSend(request, result))
   {
      trade_state.short_active = true;
      trade_state.entry_price = entry;
      trade_state.stop_loss = stop_loss;
      trade_state.take_profit = take_profit;
      trade_state.entry_time = TimeCurrent();

      Print("Short position opened. Entry: ", entry, " SL: ", stop_loss, " TP: ", take_profit);
   }
   else
   {
      Print("Failed to open short position. Error: ", result.retcode);
   }
}

//+------------------------------------------------------------------+
//| Get Long Stop Loss (recent low)                                  |
//+------------------------------------------------------------------+
double GetLongStopLoss(const MqlRates &rates[])
{
   double lowest = rates[0].low;
   for(int i = 1; i <= EntryLookback; i++)
      if(rates[i].low < lowest)
         lowest = rates[i].low;

   return lowest;
}

//+------------------------------------------------------------------+
//| Get Short Stop Loss (recent high)                                |
//+------------------------------------------------------------------+
double GetShortStopLoss(const MqlRates &rates[])
{
   double highest = rates[0].high;
   for(int i = 1; i <= EntryLookback; i++)
      if(rates[i].high > highest)
         highest = rates[i].high;

   return highest;
}

//+------------------------------------------------------------------+
//| Update Trade State                                               |
//+------------------------------------------------------------------+
void UpdateTradeState(const MqlRates &rates[], const double &ema80[])
{
   // Implementation for updating trade state
   // Check if orders are still open
   // Update trailing stops if needed
}

//+------------------------------------------------------------------+
//| Extend Profit on N Pattern                                       |
//+------------------------------------------------------------------+
void ExtendProfitOnNPattern(const MqlRates &rates[])
{
   // Implementation for N pattern recognition
   // Calculate extended take profit based on first N swing
}

//+------------------------------------------------------------------+
//| Check EMA80 Touch                                                |
//+------------------------------------------------------------------+
void CheckEMA80Touch(const MqlRates &rates[], const double &ema80[])
{
   // Implementation for EMA80 touch profit extension
   // Update take profit when price touches EMA80
}

//+------------------------------------------------------------------+
//| Close All Orders                                                 |
//+------------------------------------------------------------------+
void CloseAllOrders()
{
   // Close all open orders with Magic number
   for(int i = OrdersTotal() - 1; i >= 0; i--)
   {
      ulong ticket = OrderGetTicket(i);
      if(OrderSelectByTicket(ticket))
      {
         if(OrderGetInteger(ORDER_MAGIC) == Magic &&
            OrderGetString(ORDER_SYMBOL) == _Symbol)
         {
            MqlTradeRequest request = {};
            MqlTradeResult result = {};

            if(OrderGetInteger(ORDER_TYPE) == ORDER_TYPE_BUY)
            {
               request.action = TRADE_ACTION_SELL;
               request.volume = OrderGetDouble(ORDER_VOLUME_CURRENT);
            }
            else
            {
               request.action = TRADE_ACTION_BUY;
               request.volume = OrderGetDouble(ORDER_VOLUME_CURRENT);
            }

            request.symbol = _Symbol;
            request.price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
            request.position = ticket;

            OrderSend(request, result);
         }
      }
   }

   trade_state.long_active = false;
   trade_state.short_active = false;
}
