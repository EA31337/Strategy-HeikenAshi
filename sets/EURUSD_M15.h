//+------------------------------------------------------------------+
//|                  EA31337 - multi-strategy advanced trading robot |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_HeikinAshi_EURUSD_M15_Params : Stg_HeikinAshi_Params {
  Stg_HeikinAshi_EURUSD_M15_Params() {
    symbol = "EURUSD";
    tf = PERIOD_M15;
    HeikinAshi_Period = 2;
    HeikinAshi_Applied_Price = 3;
    HeikinAshi_Shift = 0;
    HeikinAshi_SignalOpenMethod = -63;
    HeikinAshi_SignalOpenLevel = 36;
    HeikinAshi_SignalCloseMethod = 1;
    HeikinAshi_SignalCloseLevel = 36;
    HeikinAshi_PriceLimitMethod = 0;
    HeikinAshi_PriceLimitLevel = 0;
    HeikinAshi_MaxSpread = 4;
  }
};
