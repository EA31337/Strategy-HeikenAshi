//+------------------------------------------------------------------+
//|                  EA31337 - multi-strategy advanced trading robot |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_HeikinAshi_EURUSD_H1_Params : Stg_HeikinAshi_Params {
  Stg_HeikinAshi_EURUSD_H1_Params() {
    symbol = "EURUSD";
    tf = PERIOD_H1;
    HeikinAshi_Period = 2;
    HeikinAshi_Applied_Price = 3;
    HeikinAshi_Shift = 0;
    HeikinAshi_TrailingStopMethod = 6;
    HeikinAshi_TrailingProfitMethod = 11;
    HeikinAshi_SignalOpenLevel = 36;
    HeikinAshi_SignalBaseMethod = 0;
    HeikinAshi_SignalOpenMethod1 = 195;
    HeikinAshi_SignalOpenMethod2 = 0;
    HeikinAshi_SignalCloseLevel = 36;
    HeikinAshi_SignalCloseMethod1 = 1;
    HeikinAshi_SignalCloseMethod2 = 0;
    HeikinAshi_MaxSpread = 6;
  }
};
