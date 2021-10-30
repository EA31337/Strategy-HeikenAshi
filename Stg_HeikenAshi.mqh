/**
 * @file
 * Implements HeikenAshi strategy based on the Average True Range indicator (Heiken Ashi).
 */

// User input params.
INPUT_GROUP("HeikenAshi strategy: strategy params");
INPUT float HeikenAshi_LotSize = 0;                // Lot size
INPUT int HeikenAshi_SignalOpenMethod = -9;        // Signal open method (-32-32)
INPUT float HeikenAshi_SignalOpenLevel = 0.001f;   // Signal open level
INPUT int HeikenAshi_SignalOpenFilterMethod = 32;  // Signal open filter method
INPUT int HeikenAshi_SignalOpenFilterTime = 3;     // Signal open filter time
INPUT int HeikenAshi_SignalOpenBoostMethod = 0;    // Signal open boost method
INPUT int HeikenAshi_SignalCloseMethod = 4;        // Signal close method (-32-32)
INPUT int HeikenAshi_SignalCloseFilter = 16;       // Signal close filter (-127-127)
INPUT float HeikenAshi_SignalCloseLevel = 0.001f;  // Signal close level
INPUT int HeikenAshi_PriceStopMethod = 1;          // Price stop method (0-127)
INPUT float HeikenAshi_PriceStopLevel = 2;         // Price stop level
INPUT int HeikenAshi_TickFilterMethod = 32;        // Tick filter method
INPUT float HeikenAshi_MaxSpread = 4.0;            // Max spread to trade (pips)
INPUT short HeikenAshi_Shift = 0;                  // Shift (relative to the current bar, 0 - default)
INPUT float HeikenAshi_OrderCloseLoss = 80;        // Order close loss
INPUT float HeikenAshi_OrderCloseProfit = 80;      // Order close profit
INPUT int HeikenAshi_OrderCloseTime = 0;           // Order close time in mins (>0) or bars (<0)
INPUT_GROUP("HeikenAshi strategy: HeikenAshi indicator params");
INPUT int HeikenAshi_Indi_HeikenAshi_Shift = 0;  // Shift

// Structs.
// Defines struct with default user strategy values.
struct Stg_HeikenAshi_Params_Defaults : StgParams {
  Stg_HeikenAshi_Params_Defaults()
      : StgParams(::HeikenAshi_SignalOpenMethod, ::HeikenAshi_SignalOpenFilterMethod, ::HeikenAshi_SignalOpenLevel,
                  ::HeikenAshi_SignalOpenBoostMethod, ::HeikenAshi_SignalCloseMethod, ::HeikenAshi_SignalCloseFilter,
                  ::HeikenAshi_SignalCloseLevel, ::HeikenAshi_PriceStopMethod, ::HeikenAshi_PriceStopLevel,
                  ::HeikenAshi_TickFilterMethod, ::HeikenAshi_MaxSpread, ::HeikenAshi_Shift) {
    Set(STRAT_PARAM_LS, HeikenAshi_LotSize);
    Set(STRAT_PARAM_OCL, HeikenAshi_OrderCloseLoss);
    Set(STRAT_PARAM_OCP, HeikenAshi_OrderCloseProfit);
    Set(STRAT_PARAM_OCT, HeikenAshi_OrderCloseTime);
    Set(STRAT_PARAM_SOFT, HeikenAshi_SignalOpenFilterTime);
  }
};

#ifdef __config__
// Loads pair specific param values.
#include "config/H1.h"
#include "config/H4.h"
#include "config/H8.h"
#include "config/M1.h"
#include "config/M15.h"
#include "config/M30.h"
#include "config/M5.h"
#endif

class Stg_HeikenAshi : public Strategy {
 public:
  Stg_HeikenAshi(StgParams &_sparams, TradeParams &_tparams, ChartParams &_cparams, string _name = "")
      : Strategy(_sparams, _tparams, _cparams, _name) {}

  static Stg_HeikenAshi *Init(ENUM_TIMEFRAMES _tf = NULL) {
    // Initialize strategy initial values.
    Stg_HeikenAshi_Params_Defaults stg_ha_defaults;
    StgParams _stg_params(stg_ha_defaults);
#ifdef __config__
    SetParamsByTf<StgParams>(_stg_params, _tf, stg_ha_m1, stg_ha_m5, stg_ha_m15, stg_ha_m30, stg_ha_h1, stg_ha_h4,
                             stg_ha_h8);
#endif
    // Initialize indicator.
    // Initialize Strategy instance.
    ChartParams _cparams(_tf, _Symbol);
    TradeParams _tparams;
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
   * Event on strategy's init.
   */
  void OnInit() {
    IndiHeikenAshiParams _indi_params(::HeikenAshi_Indi_HeikenAshi_Shift);
    _indi_params.SetTf(Get<ENUM_TIMEFRAMES>(STRAT_PARAM_TF));
    SetIndicator(new Indi_HeikenAshi(_indi_params));
  }

  /**
   * Check strategy's opening signal.
   */
  bool SignalOpen(ENUM_ORDER_TYPE _cmd, int _method = 0, float _level = 0.0f, int _shift = 0) {
    Indi_HeikenAshi *_indi = GetIndicator();
    bool _result =
        _indi.GetFlag(INDI_ENTRY_FLAG_IS_VALID, _shift) && _indi.GetFlag(INDI_ENTRY_FLAG_IS_VALID, _shift + 1);
    if (!_result) {
      // Returns false when indicator data is not valid.
      return false;
    }
    datetime _time = Chart().GetBarTime(_shift);
    BarOHLC _ohlc[4];
    _ohlc[0] = BarOHLC((float)_indi[_shift][(int)HA_OPEN], (float)_indi[_shift][(int)HA_HIGH],
                       (float)_indi[_shift][(int)HA_LOW], (float)_indi[_shift][(int)HA_CLOSE], _time);
    _ohlc[1] = BarOHLC((float)_indi[_shift + 1][(int)HA_OPEN], (float)_indi[_shift + 1][(int)HA_HIGH],
                       (float)_indi[_shift + 1][(int)HA_LOW], (float)_indi[_shift + 1][(int)HA_CLOSE], _time);
    _ohlc[2] = BarOHLC((float)_indi[_shift + 2][(int)HA_OPEN], (float)_indi[_shift + 2][(int)HA_HIGH],
                       (float)_indi[_shift + 2][(int)HA_LOW], (float)_indi[_shift + 2][(int)HA_CLOSE], _time);
    _ohlc[3] = BarOHLC((float)_indi[_shift + 3][(int)HA_OPEN], (float)_indi[_shift + 3][(int)HA_HIGH],
                       (float)_indi[_shift + 3][(int)HA_LOW], (float)_indi[_shift + 3][(int)HA_CLOSE], _time);
    _result &= _ohlc[0].GetRangeChangeInPct() > _level;
    switch (_cmd) {
      case ORDER_TYPE_BUY:
        _result &= _method == 0 ? PatternCandle2::CheckPattern(PATTERN_2CANDLE_BULLS, _ohlc)
                                : PatternCandle1::CheckPattern(PATTERN_1CANDLE_BULL, _ohlc[0]);
        _result &=
            _method > 0 ? PatternCandle3::CheckPattern((ENUM_PATTERN_3CANDLE)(1 << (_method - 1)), _ohlc) : _result;
        _result &=
            _method < 0 ? PatternCandle4::CheckPattern((ENUM_PATTERN_4CANDLE)(1 << -(_method + 1)), _ohlc) : _result;
        break;
      case ORDER_TYPE_SELL:
        _result &= _method == 0 ? PatternCandle2::CheckPattern(PATTERN_2CANDLE_BEARS, _ohlc)
                                : PatternCandle1::CheckPattern(PATTERN_1CANDLE_BEAR, _ohlc[0]);
        _result &=
            _method > 0 ? PatternCandle3::CheckPattern((ENUM_PATTERN_3CANDLE)(1 << (_method - 1)), _ohlc) : _result;
        _result &=
            _method < 0 ? PatternCandle4::CheckPattern((ENUM_PATTERN_4CANDLE)(1 << -(_method + 1)), _ohlc) : _result;
        break;
    }
    return _result;
  }
};
