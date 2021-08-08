/**
 * @file
 * Implements HeikenAshi strategy based on the Average True Range indicator (Heiken Ashi).
 */

// User input params.
INPUT_GROUP("HeikenAshi strategy: strategy params");
INPUT float HeikenAshi_LotSize = 0;                // Lot size
INPUT int HeikenAshi_SignalOpenMethod = 2;         // Signal open method (-127-127)
INPUT float HeikenAshi_SignalOpenLevel = 0.0f;     // Signal open level
INPUT int HeikenAshi_SignalOpenFilterMethod = 32;  // Signal open filter method
INPUT int HeikenAshi_SignalOpenBoostMethod = 0;    // Signal open boost method
INPUT int HeikenAshi_SignalCloseMethod = 2;        // Signal close method (-127-127)
INPUT int HeikenAshi_SignalCloseFilter = 0;        // Signal close filter (-127-127)
INPUT float HeikenAshi_SignalCloseLevel = 0.0f;    // Signal close level
INPUT int HeikenAshi_PriceStopMethod = 1;          // Price stop method
INPUT float HeikenAshi_PriceStopLevel = 0;         // Price stop level
INPUT int HeikenAshi_TickFilterMethod = 1;         // Tick filter method
INPUT float HeikenAshi_MaxSpread = 4.0;            // Max spread to trade (pips)
INPUT short HeikenAshi_Shift = 0;                  // Shift (relative to the current bar, 0 - default)
INPUT int HeikenAshi_OrderCloseTime = -20;         // Order close time in mins (>0) or bars (<0)
INPUT_GROUP("HeikenAshi strategy: HeikenAshi indicator params");
INPUT int HeikenAshi_Indi_HeikenAshi_Shift = 0;  // Shift

// Structs.

// Defines struct with default user indicator values.
struct Indi_HeikenAshi_Params_Defaults : HeikenAshiParams {
  Indi_HeikenAshi_Params_Defaults() : HeikenAshiParams(::HeikenAshi_Indi_HeikenAshi_Shift) {}
} indi_ha_defaults;

// Defines struct with default user strategy values.
struct Stg_HeikenAshi_Params_Defaults : StgParams {
  Stg_HeikenAshi_Params_Defaults()
      : StgParams(::HeikenAshi_SignalOpenMethod, ::HeikenAshi_SignalOpenFilterMethod, ::HeikenAshi_SignalOpenLevel,
                  ::HeikenAshi_SignalOpenBoostMethod, ::HeikenAshi_SignalCloseMethod, ::HeikenAshi_SignalCloseFilter,
                  ::HeikenAshi_SignalCloseLevel, ::HeikenAshi_PriceStopMethod, ::HeikenAshi_PriceStopLevel,
                  ::HeikenAshi_TickFilterMethod, ::HeikenAshi_MaxSpread, ::HeikenAshi_Shift,
                  ::HeikenAshi_OrderCloseTime) {}
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
#include "config/H1.h"
#include "config/H4.h"
#include "config/H8.h"
#include "config/M1.h"
#include "config/M15.h"
#include "config/M30.h"
#include "config/M5.h"

class Stg_HeikenAshi : public Strategy {
 public:
  Stg_HeikenAshi(StgParams &_sparams, TradeParams &_tparams, ChartParams &_cparams, string _name = "")
      : Strategy(_sparams, _tparams, _cparams, _name) {}

  static Stg_HeikenAshi *Init(ENUM_TIMEFRAMES _tf = NULL, long _magic_no = NULL, ENUM_LOG_LEVEL _log_level = V_INFO) {
    // Initialize strategy initial values.
    StgParams _stg_params(stg_ha_defaults);
#ifdef __config__
    SetParamsByTf<StgParams>(_stg_params, _tf, stg_ha_m1, stg_ha_m5, stg_ha_m15, stg_ha_m30, stg_ha_h1, stg_ha_h4,
                             stg_ha_h8);
#endif
    // Initialize indicator.
    HeikenAshiParams _indi_params(_tf);
    _stg_params.SetIndicator(new Indi_HeikenAshi(_indi_params));
    // Initialize Strategy instance.
    ChartParams _cparams(_tf, _Symbol);
    TradeParams _tparams(_magic_no, _log_level);
    Strategy *_strat = new Stg_HeikenAshi(_stg_params, _tparams, _cparams, "HeikenAshi");
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
    Indi_HeikenAshi *_indi = GetIndicator();
    bool _result = _indi.GetFlag(INDI_ENTRY_FLAG_IS_VALID);
    if (!_result) {
      // Returns false when indicator data is not valid.
      return false;
    }
    datetime _time = Chart().GetBarTime(_shift);
    BarOHLC _ohlc0((float)_indi[CURR][(int)HA_OPEN], (float)_indi[CURR][(int)HA_HIGH], (float)_indi[CURR][(int)HA_LOW],
                   (float)_indi[CURR][(int)HA_CLOSE], _time);
    BarOHLC _ohlc1((float)_indi[PREV][(int)HA_OPEN], (float)_indi[PREV][(int)HA_HIGH], (float)_indi[PREV][(int)HA_LOW],
                   (float)_indi[PREV][(int)HA_CLOSE], _time);
    BarOHLC _ohlc2((float)_indi[PPREV][(int)HA_OPEN], (float)_indi[PPREV][(int)HA_HIGH],
                   (float)_indi[PPREV][(int)HA_LOW], (float)_indi[PPREV][(int)HA_CLOSE], _time);
    IndicatorSignal _signals = _indi.GetSignals(4, _shift);
    switch (_cmd) {
      case ORDER_TYPE_BUY:
        _result &= _ohlc0.IsBull();
        _result &= _ohlc1.IsBear();
        _result &= _method > 0 ? _signals.CheckSignals(_method) : _signals.CheckSignalsAll(-_method);
        break;
      case ORDER_TYPE_SELL:
        _result &= _ohlc0.IsBear();
        _result &= _ohlc1.IsBull();
        _result &= _method > 0 ? _signals.CheckSignals(_method) : _signals.CheckSignalsAll(-_method);
        break;
    }
    return _result;
  }
};
