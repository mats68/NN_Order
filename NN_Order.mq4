//+------------------------------------------------------------------+
//|                                                     NN_Order.mq4 |
//|                                                       M. Thaler  |
//+------------------------------------------------------------------+
#property copyright "M. Thaler"
#property version   "1.00"
#property description  "This script generates trades according to the No Nonsense Forex money management strategy rules."
#property description  "\n\nIt takes the ATR Value for Stop and Profit Levels and computes the Position Size according to the risk."
#property description  "\n\nThe default input values conforms to VPs rules."
#property script_show_inputs
#property strict

#include "NN_Lib.mqh"

extern bool extBuy = true; // BUY (true = buy / false = sell)
extern double extRisk = 2; // Risk %
extern bool extTwoTrades = true; // 2 Trades (true = 2 Trades / false = 1 Trade)
extern double extATRSLFactor = 1.5; // ATR Factor for S/L
extern double extATRTPFactor = 1; // ATR Factor for T/P
extern int extATR = 14; // ATR Period
// Percentage the current candle must be closed to take the current candle into account for ATR calculation, else the previous candle is taken.
// The predefined value equates to 23.5  hours in daily chart
extern double extPercentCandleClosed = 97.92; // candle closed %
extern bool extAccountEquity = false; // true = Risk from Equity / false = Risk from Balance
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
   double dMODE_TICKVALUE = MarketInfo(sSymbol, MODE_TICKVALUE); //Tick value in the deposit currency z.b. EURCHF 0.9077045966160773 (1 EUR = 0.907 CHF)
   double dMODE_LOTSTEP = MarketInfo(sSymbol,MODE_LOTSTEP);
   int iMODE_DIGITS = MarketInfo(sSymbol,MODE_DIGITS);
   double dMODE_ASK = MarketInfo(sSymbol,MODE_ASK);
   double dMODE_BID = MarketInfo(sSymbol,MODE_BID);

   double dRisk = extRisk;
   if(extTwoTrades == true)
      dRisk = extRisk / 2;

   struct_PositionSize ps = CalculatePositionSize(sSymbol, dATR, pAccountBalance, dRisk, extATRSLFactor, extATRTPFactor, extBuy,
                            dMODE_TICKSIZE, dMODE_TICKVALUE, dMODE_LOTSTEP, iMODE_DIGITS, dMODE_ASK, dMODE_BID);

   int iCmd = OP_BUY;
   string sCmd = "BUY";
   if(extBuy == false)
     {
      iCmd = OP_SELL;
      sCmd = "SELL";
     }

   string title = "Place Order";
   string msg;
   if(extTwoTrades == true)
      msg = "First trade:\n\n";

   msg = msg + sCmd + " " + sSymbol +
         "\n\nRisk in %: " + DoubleToStr(dRisk, 2) +
         "\nPrice: " + DoubleToStr(ps.Prize,iMODE_DIGITS) +
         "\nSL: " + DoubleToStr(ps.dStopLoss,iMODE_DIGITS) +
         "\nTP: " +  DoubleToStr(ps.dTakeProfit,iMODE_DIGITS) +
         "\nPosition-Size: " + DoubleToStr(ps.dPositionSize,ps.iLotDigits);

   if(extTwoTrades == true)
      msg = msg + "\n\n\nSecond trade:\n\nAs above, but with empty TP";

   msg = msg + "\n\n\nATR: " + DoubleToStr(dATR,iMODE_DIGITS);

   int doTrade = MessageBox(msg, title, MB_YESNO);
   if(doTrade != IDYES)
      return;

   bool openTrades = HasOpenTradesForSymbol(sSymbol);
   if(openTrades == true)
     {
      MessageBox("There is already an open Trade with " + sSymbol);
      return;
     }


   string err = LaunchTrade(sSymbol,iCmd,ps.dPositionSize,ps.Prize,extSlippage,ps.dStopLoss,ps.dTakeProfit,extComment);
   if(err != "")
     {
      MessageBox(err);
      return;
     }
   if(extTwoTrades == true)
     {
      err = LaunchTrade(sSymbol,iCmd,ps.dPositionSize,ps.Prize,extSlippage,ps.dStopLoss,0,extComment);
      if(err != "")
        {
         MessageBox(err);
         return;
        }
     }

  }
//+------------------------------------------------------------------+
