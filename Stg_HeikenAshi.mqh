//+------------------------------------------------------------------+
//|                  EA31337 - multi-strategy advanced trading robot |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/**
 * @file
 * Implements HeikenAshi strategy based on the Average True Range indicator (Heiken Ashi).
 */

// Includes.
#include <EA31337-classes/Indicators/Indi_HeikenAshi.mqh>
#include <EA31337-classes/Strategy.mqh>

// User input params.
INPUT string __HeikenAshi_Parameters__ = "-- HeikenAshi strategy params --";  // >>> HeikenAshi <<<
INPUT int HeikenAshi_Period = 14;                                             // Averaging period
INPUT ENUM_APPLIED_PRICE HeikenAshi_Applied_Price = PRICE_HIGH;               // Applied price.
INPUT ENUM_HA_MODE HeikenAshi_Mode = HA_HIGH;       // HA mode
INPUT int HeikenAshi_Shift = 0;                     // Shift (relative to the current bar, 0 - default)
INPUT int HeikenAshi_SignalOpenMethod = 0;          // Signal open method (0-1)
INPUT double HeikenAshi_SignalOpenLevel = 0.0004;   // Signal open level (>0.0001)
INPUT int HeikenAshi_SignalOpenFilterMethod = 0;    // Signal open filter method
INPUT int HeikenAshi_SignalOpenBoostMethod = 0;     // Signal open boost method
INPUT int HeikenAshi_SignalCloseMethod = 0;         // Signal close method
INPUT double HeikenAshi_SignalCloseLevel = 0.0004;  // Signal close level (>0.0001)
INPUT int HeikenAshi_PriceLimitMethod = 0;          // Price limit method
INPUT double HeikenAshi_PriceLimitLevel = 0;        // Price limit level
INPUT double HeikenAshi_MaxSpread = 6.0;            // Max spread to trade (pips)

// Struct to define strategy parameters to override.
struct Stg_HeikenAshi_Params : StgParams {
  unsigned int HeikenAshi_Period;
  ENUM_APPLIED_PRICE HeikenAshi_Applied_Price;
  ENUM_HA_MODE HeikenAshi_Mode;
  int HeikenAshi_Shift;
  int HeikenAshi_SignalOpenMethod;
  double HeikenAshi_SignalOpenLevel;
  int HeikenAshi_SignalOpenFilterMethod;
  int HeikenAshi_SignalOpenBoostMethod;
  int HeikenAshi_SignalCloseMethod;
  double HeikenAshi_SignalCloseLevel;
  int HeikenAshi_PriceLimitMethod;
  double HeikenAshi_PriceLimitLevel;
  double HeikenAshi_MaxSpread;

  // Constructor: Set default param values.
  Stg_HeikenAshi_Params()
      : HeikenAshi_Period(::HeikenAshi_Period),
        HeikenAshi_Applied_Price(::HeikenAshi_Applied_Price),
        HeikenAshi_Mode(::HeikenAshi_Mode),
        HeikenAshi_Shift(::HeikenAshi_Shift),
        HeikenAshi_SignalOpenMethod(::HeikenAshi_SignalOpenMethod),
        HeikenAshi_SignalOpenLevel(::HeikenAshi_SignalOpenLevel),
        HeikenAshi_SignalOpenFilterMethod(::HeikenAshi_SignalOpenFilterMethod),
        HeikenAshi_SignalOpenBoostMethod(::HeikenAshi_SignalOpenBoostMethod),
        HeikenAshi_SignalCloseMethod(::HeikenAshi_SignalCloseMethod),
        HeikenAshi_SignalCloseLevel(::HeikenAshi_SignalCloseLevel),
        HeikenAshi_PriceLimitMethod(::HeikenAshi_PriceLimitMethod),
        HeikenAshi_PriceLimitLevel(::HeikenAshi_PriceLimitLevel),
        HeikenAshi_MaxSpread(::HeikenAshi_MaxSpread) {}
};

// Loads pair specific param values.
#include "sets/EURUSD_H1.h"
#include "sets/EURUSD_H4.h"
#include "sets/EURUSD_M1.h"
#include "sets/EURUSD_M15.h"
#include "sets/EURUSD_M30.h"
#include "sets/EURUSD_M5.h"

class Stg_HeikenAshi : public Strategy {
 public:
  Stg_HeikenAshi(StgParams &_params, string _name) : Strategy(_params, _name) {}

  static Stg_HeikenAshi *Init(ENUM_TIMEFRAMES _tf = NULL, long _magic_no = NULL, ENUM_LOG_LEVEL _log_level = V_INFO) {
    // Initialize strategy initial values.
    Stg_HeikenAshi_Params _params;
    if (!Terminal::IsOptimization()) {
      SetParamsByTf<Stg_HeikenAshi_Params>(_params, _tf, stg_ha_m1, stg_ha_m5, stg_ha_m15, stg_ha_m30, stg_ha_h1,
                                           stg_ha_h4, stg_ha_h4);
    }
    // Initialize strategy parameters.
    HeikenAshiParams ha_params(_tf);
    StgParams sparams(new Trade(_tf, _Symbol), new Indi_HeikenAshi(ha_params), NULL, NULL);
    sparams.logger.SetLevel(_log_level);
    sparams.SetMagicNo(_magic_no);
    sparams.SetSignals(_params.HeikenAshi_SignalOpenMethod, _params.HeikenAshi_SignalOpenMethod,
                       _params.HeikenAshi_SignalOpenFilterMethod, _params.HeikenAshi_SignalOpenBoostMethod,
                       _params.HeikenAshi_SignalCloseMethod, _params.HeikenAshi_SignalCloseMethod);
    sparams.SetMaxSpread(_params.HeikenAshi_MaxSpread);
    // Initialize strategy instance.
    Strategy *_strat = new Stg_HeikenAshi(sparams, "HeikenAshi");
    return _strat;
  }

  /**
   * Update indicator values.
   */
  /*
  bool Update(int tf = EMPTY) {
    // Calculates the Average True Range indicator.
    ratio = tf == 30 ? 1.0 : fmax(HeikenAshi_Period_Ratio, NEAR_ZERO) / tf * 30;
    for (i = 0; i < FINAL_ENUM_INDICATOR_INDEX; i++) {
      ha[index][i][FAST] = iHeikenAshi(symbol, tf, (int)(HeikenAshi_Period_Fast * ratio), i);
      ha[index][i][SLOW] = iHeikenAshi(symbol, tf, (int)(HeikenAshi_Period_Slow * ratio), i);
    }
  }
  */

  /**
   * Check strategy's opening signal.
   */
  bool SignalOpen(ENUM_ORDER_TYPE _cmd, int _method = 0, double _level = 0.0) {
    Indicator *_indi = Data();
    bool _is_valid = _indi[CURR].IsValid() && _indi[PREV].IsValid() && _indi[PPREV].IsValid();
    bool _result = _is_valid;
    double _level_pips = _level * Chart().GetPipSize();
    if (_is_valid) {
      switch (_cmd) {
        case ORDER_TYPE_BUY:
          _result = _indi[CURR].value[HeikenAshi_Mode] > _indi[PREV].value[HeikenAshi_Mode] + _level_pips; // @todo: Add _level_pips
          if (METHOD(_method, 0)) _result &= _indi[PREV].value[HeikenAshi_Mode] < _indi[PPREV].value[HeikenAshi_Mode]; // ... 2 consecutive columns are red.
          if (METHOD(_method, 1)) _result &= _indi[PPREV].value[HeikenAshi_Mode] < _indi[3].value[HeikenAshi_Mode]; // ... 3 consecutive columns are red.
          if (METHOD(_method, 2)) _result &= _indi[3].value[HeikenAshi_Mode] < _indi[4].value[HeikenAshi_Mode]; // ... 4 consecutive columns are red.
          if (METHOD(_method, 3)) _result &= _indi[PREV].value[HeikenAshi_Mode] > _indi[PPREV].value[HeikenAshi_Mode]; // ... 2 consecutive columns are green.
          if (METHOD(_method, 4)) _result &= _indi[PPREV].value[HeikenAshi_Mode] > _indi[3].value[HeikenAshi_Mode]; // ... 3 consecutive columns are green.
          if (METHOD(_method, 5)) _result &= _indi[3].value[HeikenAshi_Mode] < _indi[4].value[HeikenAshi_Mode]; // ... 4 consecutive columns are green.
          break;
        case ORDER_TYPE_SELL:
          _result = _indi[CURR].value[HeikenAshi_Mode] + _level_pips < _indi[PREV].value[HeikenAshi_Mode]; // @todo: Add _level_pips
          if (METHOD(_method, 0)) _result &= _indi[PREV].value[HeikenAshi_Mode] < _indi[PPREV].value[HeikenAshi_Mode]; // ... 2 consecutive columns are red.
          if (METHOD(_method, 1)) _result &= _indi[PPREV].value[HeikenAshi_Mode] < _indi[3].value[HeikenAshi_Mode]; // ... 3 consecutive columns are red.
          if (METHOD(_method, 2)) _result &= _indi[3].value[HeikenAshi_Mode] < _indi[4].value[HeikenAshi_Mode]; // ... 4 consecutive columns are red.
          if (METHOD(_method, 3)) _result &= _indi[PREV].value[HeikenAshi_Mode] > _indi[PPREV].value[HeikenAshi_Mode]; // ... 2 consecutive columns are green.
          if (METHOD(_method, 4)) _result &= _indi[PPREV].value[HeikenAshi_Mode] > _indi[3].value[HeikenAshi_Mode]; // ... 3 consecutive columns are green.
          if (METHOD(_method, 5)) _result &= _indi[3].value[HeikenAshi_Mode] < _indi[4].value[HeikenAshi_Mode]; // ... 4 consecutive columns are green.
          break;
      }
      Print(_indi.ToString());
    }
    return _result;
  }

  /**
   * Check strategy's opening signal additional filter.
   */
  bool SignalOpenFilter(ENUM_ORDER_TYPE _cmd, int _method = 0) {
    bool _result = true;
    if (_method != 0) {
      // if (METHOD(_method, 0)) _result &= Trade().IsTrend(_cmd);
      // if (METHOD(_method, 1)) _result &= Trade().IsPivot(_cmd);
      // if (METHOD(_method, 2)) _result &= Trade().IsPeakHours(_cmd);
      // if (METHOD(_method, 3)) _result &= Trade().IsRoundNumber(_cmd);
      // if (METHOD(_method, 4)) _result &= Trade().IsHedging(_cmd);
      // if (METHOD(_method, 5)) _result &= Trade().IsPeakBar(_cmd);
    }
    return _result;
  }

  /**
   * Gets strategy's lot size boost (when enabled).
   */
  double SignalOpenBoost(ENUM_ORDER_TYPE _cmd, int _method = 0) {
    bool _result = 1.0;
    if (_method != 0) {
      // if (METHOD(_method, 0)) if (Trade().IsTrend(_cmd)) _result *= 1.1;
      // if (METHOD(_method, 1)) if (Trade().IsPivot(_cmd)) _result *= 1.1;
      // if (METHOD(_method, 2)) if (Trade().IsPeakHours(_cmd)) _result *= 1.1;
      // if (METHOD(_method, 3)) if (Trade().IsRoundNumber(_cmd)) _result *= 1.1;
      // if (METHOD(_method, 4)) if (Trade().IsHedging(_cmd)) _result *= 1.1;
      // if (METHOD(_method, 5)) if (Trade().IsPeakBar(_cmd)) _result *= 1.1;
    }
    return _result;
  }

  /**
   * Check strategy's closing signal.
   */
  bool SignalClose(ENUM_ORDER_TYPE _cmd, int _method = 0, double _level = 0.0) {
    return SignalOpen(Order::NegateOrderType(_cmd), _method, _level);
  }

  /**
   * Gets price limit value for profit take or stop loss.
   */
  double PriceLimit(ENUM_ORDER_TYPE _cmd, ENUM_ORDER_TYPE_VALUE _mode, int _method = 0, double _level = 0.0) {
    Indicator *_indi = Data();
    bool _is_valid = _indi[CURR].IsValid() && _indi[PREV].IsValid() && _indi[PPREV].IsValid();
    double _trail = _level * Market().GetPipSize();
    int _direction = Order::OrderDirection(_cmd, _mode);
    double _default_value = Market().GetCloseOffer(_cmd) + _trail * _method * _direction;
    double _result = _default_value;
    switch (_method) {
      case 0:
        _result = (_direction < 0 ? _indi[PREV].value[HA_LOW] : _indi[PREV].value[HA_HIGH]) + _trail * _direction;
        break;
      case 1:
        _result = _indi[PREV].value[HA_OPEN] + _trail * _direction;
        break;
      case 2:
        _result = _indi[PREV].value[HA_CLOSE] + _trail * _direction;
        break;
    }
    return _result;
  }
};