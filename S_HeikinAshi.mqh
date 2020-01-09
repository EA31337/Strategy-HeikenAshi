//+------------------------------------------------------------------+
//|                 EA31337 - multi-strategy advanced trading robot. |
//|                       Copyright 2016-2017, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
    This file is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

// Properties.
#property strict

/**
 * @file
 * Implementation of HeikinAshi Strategy based on the Average True Range indicator (HeikinAshi).
 *
 * @docs
 * - https://docs.mql4.com/indicators/iHeikinAshi
 * - https://www.mql5.com/en/docs/indicators/iHeikinAshi
 */

// Includes.
#include <EA31337-classes\Strategies.mqh>
#include <EA31337-classes\Strategy.mqh>

// User inputs.

class HeikinAshi : public Strategy {
 protected:
  int open_method = EMPTY;  // Open method.
  double open_level = 0.0;  // Open level.

 public:
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
   * Checks whether signal is on buy or sell.
   *
   * @param
   *   _cmd (int) - type of trade order command
   *   period (int) - period to check for
   *   signal_method (int) - signal method to use by using bitwise AND operation
   *   signal_level (double) - signal level to consider the signal
   */
  bool Signal(int _cmd, ENUM_TIMEFRAMES tf = PERIOD_M1, int signal_method = EMPTY, double signal_level = EMPTY) {
    bool result = FALSE;
    int period = Timeframe::TfToIndex(tf);
    // UpdateIndicator(S_HeikinAshi, tf);
    // if (signal_method == EMPTY) signal_method = GetStrategySignalMethod(S_HeikinAshi, tf, 0);
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
    return result;
  }
};
