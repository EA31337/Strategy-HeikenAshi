//+------------------------------------------------------------------+
//|                  EA31337 - multi-strategy advanced trading robot |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_HeikenAshi_EURUSD_M30_Params : Stg_HeikenAshi_Params {
  Stg_HeikenAshi_EURUSD_M30_Params() {
    symbol = "EURUSD";
    tf = PERIOD_M30;
    HeikenAshi_Period = 2;
    HeikenAshi_Applied_Price = 3;
    HeikenAshi_Shift = 0;
    HeikenAshi_SignalOpenMethod = 0;
    HeikenAshi_SignalOpenLevel = 36;
    HeikenAshi_SignalCloseMethod = 1;
    HeikenAshi_SignalCloseLevel = 36;
    HeikenAshi_PriceLimitMethod = 0;
    HeikenAshi_PriceLimitLevel = 0;
    HeikenAshi_MaxSpread = 5;
  }
} stg_ha_m30;
