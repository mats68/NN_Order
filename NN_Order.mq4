//+------------------------------------------------------------------+
//|                                                     NN_Order.mq4 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property script_show_inputs
#property strict

#include "NN_Lib.mqh"

extern bool extBuy = true; // true = buy / false = sell
// Percentage the current candle must be closed to take the current candle into account, else the previous ATR value is taken. 98 equates to 23.5 hours in daily chart
extern double extPercentCandleClosed = 98; // % candle closed (1-100)
extern int extATR = 14; // ATR Period
extern double extRisk = 1; // Risk in Percent
extern double extATRSLFactor = 1.5; // SL ATR Factor
extern double extATRTPFactor = 1; // TP1 ATR Factor



//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   string sSymbol = _Symbol;
   datetime dDate = TimeCurrent();
   int iPeriod = _Period;
   double dATR = CalculateATR(sSymbol, dDate, iPeriod, extATR, extPercentCandleClosed);
   Comment("ATR: ", dATR);
   
   
   double pAccountBalance = AccountBalance();
   double dMODE_TICKSIZE = MarketInfo(sSymbol, MODE_TICKSIZE); //0.00001
   double dMODE_TICKVALUE = MarketInfo(sSymbol, MODE_TICKVALUE); //EURCHF,Daily: Tick value in the deposit currency=0.9077045966160773 (1 EUR = 0.907 CHF)
   double dMODE_LOTSTEP = MarketInfo(sSymbol,MODE_LOTSTEP);
   int iMODE_DIGITS = MarketInfo(sSymbol,MODE_DIGITS);
   double dMODE_ASK = MarketInfo(sSymbol,MODE_ASK);
   double dMODE_BID = MarketInfo(sSymbol,MODE_BID);
   
   struct_PositionSize ps = CalculatePositionSize(sSymbol, dATR, pAccountBalance, extRisk, extATRSLFactor, extATRTPFactor, extBuy, 
                 dMODE_TICKSIZE, dMODE_TICKVALUE, dMODE_LOTSTEP, iMODE_DIGITS, dMODE_ASK, dMODE_BID);
   
   Comment("\nRisk in %: ", extRisk, "\nPrice: ", ps.Prize, "\nSL: ", DoubleToStr(ps.dStopLoss,iMODE_DIGITS), "\nTP1: ", DoubleToStr(ps.dTakeProfit,iMODE_DIGITS), "\nPosition-Size: ", DoubleToStr(ps.dPPositionSize,ps.iLotDigits), "\nATR: ", dATR);
   
   
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
