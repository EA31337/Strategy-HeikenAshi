//+------------------------------------------------------------------+
//|                  EA31337 - multi-strategy advanced trading robot |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/**
 * @file
 * Implements HeikinAshi strategy based on the Average True Range indicator (HeikinAshi).
 *
 * @docs
 * - https://docs.mql4.com/indicators/iHeikinAshi
 * - https://www.mql5.com/en/docs/indicators/iHeikinAshi
 */

// Includes.
#include <EA31337-classes/Indicators/Indi_HeikenAshi.mqh>
#include <EA31337-classes/Strategy.mqh>

// User input params.
INPUT string __HeikenAshi_Parameters__ = "-- HeikenAshi strategy params --";  // >>> HeikenAshi <<<
INPUT int HeikenAshi_Active_Tf = 0;  // Activate timeframes (1-255, e.g. M1=1,M5=2,M15=4,M30=8,H1=16,H2=32,H4=64...)
INPUT int HeikenAshi_Period = 14;    // Averaging period
INPUT ENUM_APPLIED_PRICE HeikenAshi_Applied_Price = PRICE_HIGH;  // Applied price.
INPUT ENUM_TRAIL_TYPE HeikenAshi_TrailingStopMethod = 3;         // Trail stop method
INPUT ENUM_TRAIL_TYPE HeikenAshi_TrailingProfitMethod = 22;      // Trail profit method
INPUT int HeikenAshi_Shift = 0;                                  // Shift (relative to the current bar, 0 - default)
INPUT double HeikenAshi_SignalOpenLevel = 0.0004;                // Signal open level (>0.0001)
INPUT int HeikenAshi_SignalBaseMethod = 0;                       // Signal base method (0-1)
INPUT int HeikenAshi_SignalOpenMethod1 = 0;                      // Open condition 1 (0-1023)
INPUT int HeikenAshi_SignalOpenMethod2 = 0;                      // Open condition 2 (0-)
INPUT double HeikenAshi_SignalCloseLevel = 0.0004;               // Signal close level (>0.0001)
INPUT ENUM_MARKET_EVENT HeikenAshi_SignalCloseMethod1 = 0;       // Signal close method 1
INPUT ENUM_MARKET_EVENT HeikenAshi_SignalCloseMethod2 = 0;       // Signal close method 2
INPUT double HeikenAshi_MaxSpread = 6.0;                         // Max spread to trade (pips)

// Struct to define strategy parameters to override.
struct Stg_HeikinAshi_Params : Stg_Params {
  unsigned int HeikinAshi_Period;
  ENUM_APPLIED_PRICE HeikinAshi_Applied_Price;
  int HeikinAshi_Shift;
  ENUM_TRAIL_TYPE HeikinAshi_TrailingStopMethod;
  ENUM_TRAIL_TYPE HeikinAshi_TrailingProfitMethod;
  double HeikinAshi_SignalOpenLevel;
  long HeikinAshi_SignalBaseMethod;
  long HeikinAshi_SignalOpenMethod1;
  long HeikinAshi_SignalOpenMethod2;
  double HeikinAshi_SignalCloseLevel;
  ENUM_MARKET_EVENT HeikinAshi_SignalCloseMethod1;
  ENUM_MARKET_EVENT HeikinAshi_SignalCloseMethod2;
  double HeikinAshi_MaxSpread;

  // Constructor: Set default param values.
  Stg_HeikinAshi_Params()
      : HeikinAshi_Period(::HeikinAshi_Period),
        HeikinAshi_Applied_Price(::HeikinAshi_Applied_Price),
        HeikinAshi_Shift(::HeikinAshi_Shift),
        HeikinAshi_TrailingStopMethod(::HeikinAshi_TrailingStopMethod),
        HeikinAshi_TrailingProfitMethod(::HeikinAshi_TrailingProfitMethod),
        HeikinAshi_SignalOpenLevel(::HeikinAshi_SignalOpenLevel),
        HeikinAshi_SignalBaseMethod(::HeikinAshi_SignalBaseMethod),
        HeikinAshi_SignalOpenMethod1(::HeikinAshi_SignalOpenMethod1),
        HeikinAshi_SignalOpenMethod2(::HeikinAshi_SignalOpenMethod2),
        HeikinAshi_SignalCloseLevel(::HeikinAshi_SignalCloseLevel),
        HeikinAshi_SignalCloseMethod1(::HeikinAshi_SignalCloseMethod1),
        HeikinAshi_SignalCloseMethod2(::HeikinAshi_SignalCloseMethod2),
        HeikinAshi_MaxSpread(::HeikinAshi_MaxSpread) {}
};

// Loads pair specific param values.
#include "sets/EURUSD_H1.h"
#include "sets/EURUSD_H4.h"
#include "sets/EURUSD_M1.h"
#include "sets/EURUSD_M15.h"
#include "sets/EURUSD_M30.h"
#include "sets/EURUSD_M5.h"

class HeikinAshi : public Strategy {
 public:
  Stg_HeikenAshi(StgParams &_params, string _name) : Strategy(_params, _name) {}

  static Stg_HeikinAshi *Init(ENUM_TIMEFRAMES _tf = NULL, long _magic_no = NULL, ENUM_LOG_LEVEL _log_level = V_INFO) {
    // Initialize strategy initial values.
    Stg_HeikinAshi_Params _params;
    switch (_tf) {
      case PERIOD_M1: {
        Stg_HeikinAshi_EURUSD_M1_Params _new_params;
        _params = _new_params;
      }
      case PERIOD_M5: {
        Stg_HeikinAshi_EURUSD_M5_Params _new_params;
        _params = _new_params;
      }
      case PERIOD_M15: {
        Stg_HeikinAshi_EURUSD_M15_Params _new_params;
        _params = _new_params;
      }
      case PERIOD_M30: {
        Stg_HeikinAshi_EURUSD_M30_Params _new_params;
        _params = _new_params;
      }
      case PERIOD_H1: {
        Stg_HeikinAshi_EURUSD_H1_Params _new_params;
        _params = _new_params;
      }
      case PERIOD_H4: {
        Stg_HeikinAshi_EURUSD_H4_Params _new_params;
        _params = _new_params;
      }
    }
    // Initialize strategy parameters.
    ChartParams cparams(_tf);
    HeikinAshi_Params adx_params(_params.HeikinAshi_Period, _params.HeikinAshi_Applied_Price);
    IndicatorParams adx_iparams(10, INDI_HeikinAshi);
    StgParams sparams(new Trade(_tf, _Symbol), new Indi_HeikinAshi(adx_params, adx_iparams, cparams), NULL, NULL);
    sparams.logger.SetLevel(_log_level);
    sparams.SetMagicNo(_magic_no);
    sparams.SetSignals(_params.HeikinAshi_SignalBaseMethod, _params.HeikinAshi_SignalOpenMethod1,
                       _params.HeikinAshi_SignalOpenMethod2, _params.HeikinAshi_SignalCloseMethod1,
                       _params.HeikinAshi_SignalCloseMethod2, _params.HeikinAshi_SignalOpenLevel,
                       _params.HeikinAshi_SignalCloseLevel);
    sparams.SetStops(_params.HeikinAshi_TrailingProfitMethod, _params.HeikinAshi_TrailingStopMethod);
    sparams.SetMaxSpread(_params.HeikinAshi_MaxSpread);
    // Initialize strategy instance.
    Strategy *_strat = new Stg_HeikinAshi(sparams, "HeikinAshi");
    return _strat;
  }

  /**
   * Update indicator values.
   */
  bool Update(int tf = EMPTY) {
    // Calculates the Average True Range indicator.
    ratio = tf == 30 ? 1.0 : fmax(HeikinAshi_Period_Ratio, NEAR_ZERO) / tf * 30;
    for (i = 0; i < FINAL_ENUM_INDICATOR_INDEX; i++) {
      ha[index][i][FAST] = iHeikinAshi(symbol, tf, (int)(HeikinAshi_Period_Fast * ratio), i);
      ha[index][i][SLOW] = iHeikinAshi(symbol, tf, (int)(HeikinAshi_Period_Slow * ratio), i);
    }
  }

  /**
   * Check strategy's opening signal.
   */
  bool SignalOpen(ENUM_ORDER_TYPE _cmd, long _signal_method = EMPTY, double _signal_level = EMPTY) {
    bool _result = false;
    // UpdateIndicator(S_HeikinAshi, tf);
    // if (signal_method == EMPTY) signal_method = GetStrategySignalBaseMethod(S_HeikinAshi, tf, 0);
    // if (signal_level  == EMPTY) signal_level  = GetStrategySignalLevel(S_HeikinAshi, tf, 0.0);
    switch (_cmd) {
      //   if(iHeikinAshi(NULL,0,12,0)>iHeikinAshi(NULL,0,20,0)) return(0);
      /*
        //6. Average True Range - HeikinAshi
        //Doesn't give independent signals. Is used to define volatility (trend strength).
        //principle: trend must be strengthened. Together with that HeikinAshi grows.
        //Because of the chart form it is inconvenient to analyze rise/fall. Only exceeding of threshold value is
        checked.
        //Flag is 1 when HeikinAshi is above threshold value (i.e. there is a trend), 0 - when HeikinAshi is below
        threshold value, -1 - never. if (iHeikinAshi(NULL,piha,pihau,0)>=minha) {f6=1;}
      */
      case OP_BUY:
        /*
          bool result = HeikinAshi[period][CURR][LOWER] != 0.0 || HeikinAshi[period][PREV][LOWER] != 0.0 ||
          HeikinAshi[period][FAR][LOWER] != 0.0; if ((signal_method &   1) != 0) result &= Open[CURR] > Close[CURR]; if
          ((signal_method &   2) != 0) result &= !HeikinAshi_On_Sell(tf); if ((signal_method &   4) != 0) result &=
          HeikinAshi_On_Buy(fmin(period + 1, M30)); if ((signal_method &   8) != 0) result &= HeikinAshi_On_Buy(M30); if
          ((signal_method &  16) != 0) result &= HeikinAshi[period][FAR][LOWER] != 0.0; if ((signal_method &  32) != 0)
          result &= !HeikinAshi_On_Sell(M30);
          */
        break;
      case OP_SELL:
        /*
          bool result = HeikinAshi[period][CURR][UPPER] != 0.0 || HeikinAshi[period][PREV][UPPER] != 0.0 ||
          HeikinAshi[period][FAR][UPPER] != 0.0; if ((signal_method &   1) != 0) result &= Open[CURR] < Close[CURR]; if
          ((signal_method &   2) != 0) result &= !HeikinAshi_On_Buy(tf); if ((signal_method &   4) != 0) result &=
          HeikinAshi_On_Sell(fmin(period + 1, M30)); if ((signal_method &   8) != 0) result &= HeikinAshi_On_Sell(M30);
          if ((signal_method &  16) != 0) result &= HeikinAshi[period][FAR][UPPER] != 0.0;
          if ((signal_method &  32) != 0) result &= !HeikinAshi_On_Buy(M30);
          */
        break;
    }
    return _result;
  }

  /**
   * Check strategy's closing signal.
   */
  bool SignalClose(ENUM_ORDER_TYPE _cmd, long _signal_method = EMPTY, double _signal_level = EMPTY) {
    if (_signal_level == EMPTY) _signal_level = GetSignalCloseLevel();
    return SignalOpen(Order::NegateOrderType(_cmd), _signal_method, _signal_level);
  }
};
