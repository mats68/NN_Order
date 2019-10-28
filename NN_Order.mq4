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
// Percentage the current candle must be closed to take the current candle into account, else the previous ATR value is taken. 
// The predefined value equates to 23.5  hours in daily chart
extern double extPercentCandleClosed = 97.92; // % candle closed 
extern int extATR = 14; // ATR Period
extern double extRisk = 1; // Risk in Percent
extern bool extAccountEquity = false; // true = Risk from Equity / false = Risk from Balance
extern double extATRSLFactor = 1.5; // SL ATR Factor
extern double extATRTPFactor = 1; // TP1 ATR Factor
//---
extern int extSlippage = 3; // Max. price slippage
extern string extComment=NULL; // Order comment text


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

   double pAccountBalance = AccountBalance();
   if(extAccountEquity == true)
     {
      pAccountBalance = AccountEquity();
     }
   double dMODE_TICKSIZE = MarketInfo(sSymbol, MODE_TICKSIZE); //0.00001 kleinstmögliche Veränderung des Preises
   double dMODE_TICKVALUE = MarketInfo(sSymbol, MODE_TICKVALUE); //EURCHF,Daily: Tick value in the deposit currency=0.9077045966160773 (1 EUR = 0.907 CHF)
   double dMODE_LOTSTEP = MarketInfo(sSymbol,MODE_LOTSTEP);
   int iMODE_DIGITS = MarketInfo(sSymbol,MODE_DIGITS);
   double dMODE_ASK = MarketInfo(sSymbol,MODE_ASK);
   double dMODE_BID = MarketInfo(sSymbol,MODE_BID);

   struct_PositionSize ps = CalculatePositionSize(sSymbol, dATR, pAccountBalance, extRisk, extATRSLFactor, extATRTPFactor, extBuy,
                            dMODE_TICKSIZE, dMODE_TICKVALUE, dMODE_LOTSTEP, iMODE_DIGITS, dMODE_ASK, dMODE_BID);

   int iCmd = OP_BUY;
   string sCmd = "BUY";
   if(extBuy == false)
     {
      iCmd = OP_SELL;
      sCmd = "SELL";
     }

   string title = "Place Order";
   string msg = "First trade:\n\n" + sCmd + " " + sSymbol +
                "\n\nRisk in %: " + DoubleToStr(extRisk, 2) +
                "\nPrice: " + DoubleToStr(ps.Prize,iMODE_DIGITS) +
                "\nSL: " + DoubleToStr(ps.dStopLoss,iMODE_DIGITS) +
                "\nTP: " +  DoubleToStr(ps.dTakeProfit,iMODE_DIGITS) +
                "\nPosition-Size: " + DoubleToStr(ps.dPositionSize,ps.iLotDigits) +
                "\n\n\nSecond trade:\n\nAs above, but with empty TP" +
                "\n\n\nATR: " + DoubleToStr(dATR,iMODE_DIGITS);

   int doTrade = MessageBox(msg, title, MB_YESNO);
   if(doTrade != IDYES)
      return;

   bool openTrades = OpenTradesForSymbol(sSymbol);
   if(openTrades == true)
     {
      MessageBox("There is already an open Trade with " + sSymbol);
      return;
     }


   string err = OpenOrders(sSymbol,iCmd,ps.dPositionSize,ps.Prize,extSlippage,ps.dStopLoss,ps.dTakeProfit,extComment);
   if(err != "")
     {
      MessageBox(err);
      return;
     }

   err = OpenOrders(sSymbol,iCmd,ps.dPositionSize,ps.Prize,extSlippage,ps.dStopLoss,0,extComment);
   if(err != "")
     {
      MessageBox(err);
      return;
     }
  }
//+------------------------------------------------------------------+
