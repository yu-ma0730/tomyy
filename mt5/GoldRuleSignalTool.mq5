//+------------------------------------------------------------------+
//| Gold Regularity Signal Tool for MT5
//| Detects EMA-based trading signals for Gold (15min chart)
//| Uses: EMA 10, 20, 40, 80
//+------------------------------------------------------------------+
#property copyright "Gold Regularity Strategy"
#property version   "1.0"
#property description "Gold Trading Signal Tool based on EMA Regularity"
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   4

input bool EnableAlerts = true;
input bool EnableNotifications = false;
input color UpSignalColor = clrGreen;
input color DownSignalColor = clrRed;
input int SignalSize = 2;

double upSignalBuffer[];
double downSignalBuffer[];
double emaAlertBuffer[];
double zoneAlertBuffer[];

int ema10Handle, ema20Handle, ema40Handle, ema80Handle;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
    SetIndexBuffer(0, upSignalBuffer, INDICATOR_DATA);
    SetIndexBuffer(1, downSignalBuffer, INDICATOR_DATA);
    SetIndexBuffer(2, emaAlertBuffer, INDICATOR_DATA);
    SetIndexBuffer(3, zoneAlertBuffer, INDICATOR_DATA);

    PlotIndexSetInteger(0, PLOT_TYPE, PLOT_TYPE_ARROW);
    PlotIndexSetInteger(0, PLOT_ARROW, 233);
    PlotIndexSetInteger(0, PLOT_COLOR_INDEXES, 1);
    PlotIndexSetInteger(0, PLOT_LINE_COLOR, 0, UpSignalColor);
    PlotIndexSetInteger(0, PLOT_LINE_WIDTH, SignalSize);

    PlotIndexSetInteger(1, PLOT_TYPE, PLOT_TYPE_ARROW);
    PlotIndexSetInteger(1, PLOT_ARROW, 234);
    PlotIndexSetInteger(1, PLOT_COLOR_INDEXES, 1);
    PlotIndexSetInteger(1, PLOT_LINE_COLOR, 0, DownSignalColor);
    PlotIndexSetInteger(1, PLOT_LINE_WIDTH, SignalSize);

    PlotIndexSetInteger(2, PLOT_TYPE, PLOT_TYPE_LINE);
    PlotIndexSetInteger(2, PLOT_STYLE, PSTYLE_DOT);
    PlotIndexSetInteger(2, PLOT_LINE_COLOR, 0, clrOrange);
    PlotIndexSetInteger(2, PLOT_SHOW_DATA, false);

    PlotIndexSetInteger(3, PLOT_TYPE, PLOT_TYPE_LINE);
    PlotIndexSetInteger(3, PLOT_STYLE, PSTYLE_DASH);
    PlotIndexSetInteger(3, PLOT_LINE_COLOR, 0, clrGray);
    PlotIndexSetInteger(3, PLOT_SHOW_DATA, false);

    IndicatorSetString(INDICATOR_SHORTNAME, "Gold Regularity Signal");

    ema10Handle = iMA(_Symbol, PERIOD_CURRENT, 10, 0, MODE_EMA);
    ema20Handle = iMA(_Symbol, PERIOD_CURRENT, 20, 0, MODE_EMA);
    ema40Handle = iMA(_Symbol, PERIOD_CURRENT, 40, 0, MODE_EMA);
    ema80Handle = iMA(_Symbol, PERIOD_CURRENT, 80, 0, MODE_EMA);

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
    if(rates_total < 100) return 0;

    double ema10[], ema20[], ema40[], ema80[];
    ArraySetAsSeries(ema10, true);
    ArraySetAsSeries(ema20, true);
    ArraySetAsSeries(ema40, true);
    ArraySetAsSeries(ema80, true);

    CopyBuffer(ema10Handle, 0, 0, 3, ema10);
    CopyBuffer(ema20Handle, 0, 0, 3, ema20);
    CopyBuffer(ema40Handle, 0, 0, 3, ema40);
    CopyBuffer(ema80Handle, 0, 0, 3, ema80);

    ArraySetAsSeries(close, true);
    ArraySetAsSeries(open, true);
    ArraySetAsSeries(high, true);
    ArraySetAsSeries(low, true);

    int start = prev_calculated > 1 ? prev_calculated - 1 : 1;

    for(int i = start; i < rates_total; i++)
    {
        upSignalBuffer[i] = EMPTY_VALUE;
        downSignalBuffer[i] = EMPTY_VALUE;
        emaAlertBuffer[i] = EMPTY_VALUE;
        zoneAlertBuffer[i] = EMPTY_VALUE;

        // Rule: EMA10 downbreak -> detect SHORT signal
        if(i >= 1 && close[i] < ema10[i] && close[i+1] >= ema10[i+1])
        {
            downSignalBuffer[i] = high[i] + (high[i] - low[i]) * 0.5;
            if(EnableAlerts) Alert("SHORT Signal: Price broke below EMA10");
            if(EnableNotifications) SendNotification("SHORT Signal: EMA10 Downbreak on " + _Symbol);
        }

        // Rule: EMA20 multiple bounces detection
        if(i >= 1 && IsEMA20Bounce(close, ema20, i))
        {
            emaAlertBuffer[i] = ema20[i] + (ema20[i] * 0.001);
            if(EnableAlerts) Alert("EMA20 Bounce Detected - High Probability Zone");
        }

        // Rule: Price approaching EMA20 from below after EMA10 break
        if(i >= 1 && close[i] > ema10[i] && close[i+1] <= ema10[i+1] && close[i] < ema20[i])
        {
            zoneAlertBuffer[i] = ema20[i];
            if(EnableAlerts) Alert("Recovery Zone: Watch EMA20");
        }

        // Rule: Price touches EMA in sequence (support/resistance)
        if(i >= 2 && IsPerfectOrder(ema10[i], ema20[i], ema40[i], ema80[i], close[i]))
        {
            if(close[i] < ema10[i] && close[i+1] >= ema10[i+1])
            {
                downSignalBuffer[i] = high[i] + (high[i] - low[i]) * 0.8;
            }
        }
    }

    return rates_total;
}

//+------------------------------------------------------------------+
//| Check if price bounces off EMA20 (Rule #3)
//+------------------------------------------------------------------+
bool IsEMA20Bounce(const double &close[], const double &ema20[], int pos)
{
    if(pos < 2) return false;

    // Price was above EMA20, then touched it, then bounced
    if(close[pos+2] > ema20[pos+2] &&
       MathAbs(close[pos+1] - ema20[pos+1]) < ema20[pos+1] * 0.005 &&
       close[pos] > ema20[pos])
    {
        return true;
    }
    return false;
}

//+------------------------------------------------------------------+
//| Check Perfect Order (EMA sequence alignment)
//+------------------------------------------------------------------+
bool IsPerfectOrder(double ema10, double ema20, double ema40, double ema80, double price)
{
    // Uptrend: Price > EMA10 > EMA20 > EMA40 > EMA80
    if(price > ema10 && ema10 > ema20 && ema20 > ema40 && ema40 > ema80)
        return true;

    // Downtrend: Price < EMA10 < EMA20 < EMA40 < EMA80
    if(price < ema10 && ema10 < ema20 && ema20 < ema40 && ema40 < ema80)
        return true;

    return false;
}

//+------------------------------------------------------------------+
//| OnDeinit
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    ReleaseBUFFER(ema10Handle);
    ReleaseBUFFER(ema20Handle);
    ReleaseBUFFER(ema40Handle);
    ReleaseBUFFER(ema80Handle);
}

void ReleaseBUFFER(int handle)
{
    if(handle != INVALID_HANDLE)
        IndicatorRelease(handle);
}
