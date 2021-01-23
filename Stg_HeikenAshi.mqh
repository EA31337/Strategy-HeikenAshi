/**
 * @file
 * Implements HeikenAshi strategy based on the Average True Range indicator (Heiken Ashi).
 */

// User input params.
INPUT string __HeikenAshi_Parameters__ = "-- HeikenAshi strategy params --";  // >>> HeikenAshi <<<
INPUT float HeikenAshi_LotSize = 0;                                           // Lot size
INPUT int HeikenAshi_SignalOpenMethod = 0;                                    // Signal open method (-3-3)
INPUT float HeikenAshi_SignalOpenLevel = 0.0f;                                // Signal open level
INPUT int HeikenAshi_SignalOpenFilterMethod = 1;                              // Signal open filter method
INPUT int HeikenAshi_SignalOpenBoostMethod = 0;                               // Signal open boost method
INPUT int HeikenAshi_SignalCloseMethod = 0;                                   // Signal close method (-3-3)
INPUT float HeikenAshi_SignalCloseLevel = 0.0f;                               // Signal close level
INPUT int HeikenAshi_PriceStopMethod = 0;                                     // Price stop method
INPUT float HeikenAshi_PriceStopLevel = 0;                                    // Price stop level
INPUT int HeikenAshi_TickFilterMethod = 1;                                    // Tick filter method
INPUT float HeikenAshi_MaxSpread = 4.0;                                       // Max spread to trade (pips)
INPUT int HeikenAshi_Shift = 0;             // Shift (relative to the current bar, 0 - default)
INPUT int HeikenAshi_OrderCloseTime = -20;  // Order close time in mins (>0) or bars (<0)
INPUT string __HeikenAshi_Indi_HeikenAshi_Parameters__ =
    "-- HeikenAshi strategy: HeikenAshi indicator params --";  // >>> HeikenAshi strategy: HeikenAshi indicator <<<
INPUT int HeikenAshi_Indi_HeikenAshi_Shift = 0;                // Shift

// Structs.

// Defines struct with default user indicator values.
struct Indi_HeikenAshi_Params_Defaults : HeikenAshiParams {
  Indi_HeikenAshi_Params_Defaults() : HeikenAshiParams(::HeikenAshi_Indi_HeikenAshi_Shift) {}
} indi_ha_defaults;

// Defines struct with default user strategy values.
struct Stg_HeikenAshi_Params_Defaults : StgParams {
  Stg_HeikenAshi_Params_Defaults()
      : StgParams(::HeikenAshi_SignalOpenMethod, ::HeikenAshi_SignalOpenFilterMethod, ::HeikenAshi_SignalOpenLevel,
                  ::HeikenAshi_SignalOpenBoostMethod, ::HeikenAshi_SignalCloseMethod, ::HeikenAshi_SignalCloseLevel,
                  ::HeikenAshi_PriceStopMethod, ::HeikenAshi_PriceStopLevel, ::HeikenAshi_TickFilterMethod,
                  ::HeikenAshi_MaxSpread, ::HeikenAshi_Shift, ::HeikenAshi_OrderCloseTime) {}
} stg_ha_defaults;

// Struct to define strategy parameters to override.
struct Stg_HeikenAshi_Params : StgParams {
  StgParams sparams;

  // Struct constructors.
  Stg_HeikenAshi_Params(HeikenAshiParams &_iparams, StgParams &_sparams) : sparams(stg_ha_defaults) {
    sparams = _sparams;
  }
};

// Loads pair specific param values.
#include "config/EURUSD_H1.h"
#include "config/EURUSD_H4.h"
#include "config/EURUSD_H8.h"
#include "config/EURUSD_M1.h"
#include "config/EURUSD_M15.h"
#include "config/EURUSD_M30.h"
#include "config/EURUSD_M5.h"

class Stg_HeikenAshi : public Strategy {
 public:
  Stg_HeikenAshi(StgParams &_params, string _name) : Strategy(_params, _name) {}

  static Stg_HeikenAshi *Init(ENUM_TIMEFRAMES _tf = NULL, long _magic_no = NULL, ENUM_LOG_LEVEL _log_level = V_INFO) {
    // Initialize strategy initial values.
    StgParams _stg_params(stg_ha_defaults);
    if (!Terminal::IsOptimization()) {
      SetParamsByTf<StgParams>(_stg_params, _tf, stg_ha_m1, stg_ha_m5, stg_ha_m15, stg_ha_m30, stg_ha_h1, stg_ha_h4,
                               stg_ha_h8);
    }
    // Initialize indicator.
    HeikenAshiParams _indi_params(_tf);
    _stg_params.SetIndicator(new Indi_HeikenAshi(_indi_params));
    // Initialize strategy parameters.
    _stg_params.GetLog().SetLevel(_log_level);
    _stg_params.SetMagicNo(_magic_no);
    _stg_params.SetTf(_tf, _Symbol);
    // Initialize strategy instance.
    Strategy *_strat = new Stg_HeikenAshi(_stg_params, "HeikenAshi");
    _stg_params.SetStops(_strat, _strat);
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
  bool SignalOpen(ENUM_ORDER_TYPE _cmd, int _method = 0, float _level = 0.0f, int _shift = 0) {
    Indi_HeikenAshi *_indi = Data();
    bool _is_valid = _indi[CURR].IsValid() && _indi[PREV].IsValid() && _indi[PPREV].IsValid();
    bool _result = _is_valid;
    if (_is_valid) {
      datetime _time = Chart().GetBarTime(_shift);
      BarOHLC _ohlc0((float)_indi[CURR][(int)HA_OPEN], (float)_indi[CURR][(int)HA_HIGH],
                     (float)_indi[CURR][(int)HA_LOW], (float)_indi[CURR][(int)HA_CLOSE], _time);
      BarOHLC _ohlc1((float)_indi[PREV][(int)HA_OPEN], (float)_indi[PREV][(int)HA_HIGH],
                     (float)_indi[PREV][(int)HA_LOW], (float)_indi[PREV][(int)HA_CLOSE], _time);
      BarOHLC _ohlc2((float)_indi[PPREV][(int)HA_OPEN], (float)_indi[PPREV][(int)HA_HIGH],
                     (float)_indi[PPREV][(int)HA_LOW], (float)_indi[PPREV][(int)HA_CLOSE], _time);
      switch (_cmd) {
        case ORDER_TYPE_BUY:
          _result &= _ohlc0.GetChangeInPct(true) > _level;
          _result &= _ohlc0.isBullish();
          _result &= _ohlc1.isBearish();
          if (METHOD(_method, 0)) _result &= _ohlc2.isBearish();
          if (METHOD(_method, 1)) _result &= _ohlc1.GetChangeInPct(true) > _level;
          break;
        case ORDER_TYPE_SELL:
          _result &= _ohlc0.GetChangeInPct(true) < -_level;
          _result &= _ohlc0.isBearish();
          _result &= _ohlc1.isBullish();
          if (METHOD(_method, 0)) _result &= _ohlc2.isBullish();
          if (METHOD(_method, 1)) _result &= _ohlc1.GetChangeInPct(true) < -_level;
          break;
      }
      Print(_indi.ToString());
    }
    return _result;
  }

  /**
   * Gets price stop value for profit take or stop loss.
   */
  float PriceStop(ENUM_ORDER_TYPE _cmd, ENUM_ORDER_TYPE_VALUE _mode, int _method = 0, float _level = 0.0) {
    Indi_HeikenAshi *_indi = Data();
    bool _is_valid = _indi[CURR].IsValid() && _indi[PREV].IsValid() && _indi[PPREV].IsValid();
    double _trail = _level * Market().GetPipSize();
    int _direction = Order::OrderDirection(_cmd, _mode);
    double _default_value = Market().GetCloseOffer(_cmd) + _trail * _method * _direction;
    double _result = _default_value;
    switch (_method) {
      case 1:
        _result = (_direction < 0 ? _indi[PREV][(int)HA_LOW] : _indi[PREV][(int)HA_HIGH]) + _trail * _direction;
        break;
      case 2:
        _result = _indi[PREV][(int)HA_OPEN] + _trail * _direction;
        break;
      case 3:
        _result = _indi[PREV][(int)HA_CLOSE] + _trail * _direction;
        break;
      case 4: {
        int _bar_count = (int)_level * 10;
        _result = _direction > 0 ? _indi.GetPrice(PRICE_HIGH, _indi.GetHighest<double>(_bar_count))
                                 : _indi.GetPrice(PRICE_LOW, _indi.GetLowest<double>(_bar_count));
        break;
      }
    }
    return (float)_result;
  }
};
