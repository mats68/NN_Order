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

enum tradeOperation {
  BUY=0,
  SELL=1
};

enum tradeCount {
  ONE=1,  // 1 Trade
  TWO=2   // 2 Trades
};

enum amountType {
  BALANCE=1,  // Balance
  EQUITY=2,   // Equity
  FREEMARGIN=3   // Free Margin
};

enum pendingOperation {
  PEND_NONE = 0, //Market Execution
  BUY_LIMIT=2,
  SELL_LIMIT=3,
  BUY_STOP=4,
  SELL_STOP=5
};


extern tradeOperation extOp = BUY;  // Operation
extern double extRisk = 2; // Risk %
extern tradeCount extTradeCount = TWO; // Trades Count
extern double extATRSLFactor = 1.5; // ATR Factor for S/L
extern double extATRTPFactor = 1; // ATR Factor for T/P
extern int extATR = 14; // ATR Period
// Percentage the current candle must be closed to take the current candle into account for ATR calculation, else the previous candle is taken.
// The predefined value equates to 23.5  hours in daily chart
extern double extPercentCandleClosed = 97.92; // candle closed %
extern amountType extAmountType = BALANCE; // Risk from Amount
extern int extSlippage = 3; // Max. price slippage
extern string extComment=NULL; // Order comment text
// -- Pending Order
extern pendingOperation extPendingOperation = PEND_NONE;
extern double extPendingPrice = 0; //Price pending order


//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart() {
//---
  string sSymbol = _Symbol;
  datetime dDate = TimeCurrent();
  int iPeriod = _Period;

  double dATR = CalculateATR(sSymbol, dDate, iPeriod, extATR, extPercentCandleClosed);

  double pAccountBalance = AccountBalance();
  if(extAmountType == EQUITY) {
    pAccountBalance = AccountEquity();
  } else if (extAmountType == FREEMARGIN) {
    pAccountBalance = AccountFreeMargin();
  }
  double dMODE_TICKSIZE = MarketInfo(sSymbol, MODE_TICKSIZE); //0.00001 kleinstmögliche Veränderung des Preises
  double dMODE_TICKVALUE = MarketInfo(sSymbol, MODE_TICKVALUE); //Tick value in the deposit currency z.b. EURCHF 0.9077045966160773 (1 EUR = 0.907 CHF)
  double dMODE_LOTSTEP = MarketInfo(sSymbol,MODE_LOTSTEP);
  int iMODE_DIGITS = MarketInfo(sSymbol,MODE_DIGITS);
  double dMODE_ASK = MarketInfo(sSymbol,MODE_ASK);
  double dMODE_BID = MarketInfo(sSymbol,MODE_BID);

  double dRisk = extRisk;
  if(extTradeCount == TWO)
    dRisk = extRisk / 2;


  int cmdOrder = OP_BUY;
  bool dBuy = true;
  string sCmd = "BUY";
  double dPrice = dMODE_ASK;
  if (extPendingOperation == PEND_NONE && extOp == SELL) {
    dPrice = dMODE_BID;
    cmdOrder = OP_SELL;
    dBuy = false;
    sCmd = "SELL";
  }
  if (extPendingOperation != PEND_NONE) {
    dPrice = extPendingPrice;
    if (extPendingOperation == SELL_STOP) {
      dBuy = false;
      cmdOrder = OP_SELLSTOP;
      sCmd = "SELL STOP";
    } else if(extPendingOperation == SELL_LIMIT) {
      dBuy = false;
      cmdOrder = OP_SELLLIMIT;
      sCmd = "SELL LIMIT";
    } else if(extPendingOperation == BUY_STOP) {
      cmdOrder = OP_BUYSTOP;
      sCmd = "BUY STOP";
    } else if(extPendingOperation == BUY_LIMIT) {
      cmdOrder = OP_BUYLIMIT;
      sCmd = "BUY LIMIT";
    }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
  struct_PositionSize ps = CalculatePositionSize(sSymbol, dATR, pAccountBalance, dRisk, extATRSLFactor, extATRTPFactor, dBuy,
                           dMODE_TICKSIZE, dMODE_TICKVALUE, dMODE_LOTSTEP, iMODE_DIGITS, dPrice);

  string title = "Place Order";
  string msg;
  if(extTradeCount == TWO)
    msg = "First trade:\n\n";

  msg = msg + sCmd + " " + sSymbol +
        "\n\nRisk in %: " + DoubleToStr(dRisk, 2) +
        "\nPrice: " + DoubleToStr(dPrice,iMODE_DIGITS) +
        "\nSL: " + DoubleToStr(ps.dStopLoss,iMODE_DIGITS) +
        "\nTP: " +  DoubleToStr(ps.dTakeProfit,iMODE_DIGITS) +
        "\nPosition-Size: " + DoubleToStr(ps.dPositionSize,ps.iLotDigits);

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
  if(extTradeCount == TWO)
    msg = msg + "\n\n\nSecond trade:\n\nAs above, but with empty TP";

  msg = msg + "\n\n\nATR: " + DoubleToStr(dATR,iMODE_DIGITS);

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
  int doTrade = MessageBox(msg, title, MB_YESNO);
  if(doTrade != IDYES)
    return;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
  bool openTrades = HasOpenTradesForSymbol(sSymbol);
  if(openTrades == true) {
    doTrade = MessageBox("There is already an open Trade with " + sSymbol + ". Continue ?", "Warning", MB_YESNO);
    if(doTrade != IDYES)
      return;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
  string err = LaunchTrade(sSymbol,cmdOrder,ps.dPositionSize,dPrice,extSlippage,ps.dStopLoss,ps.dTakeProfit,extComment);
  if(err != "") {
    MessageBox(err);
    return;
  }
  if(extTradeCount == TWO) {
    err = LaunchTrade(sSymbol,cmdOrder,ps.dPositionSize,dPrice,extSlippage,ps.dStopLoss,0,extComment);
    if(err != "") {
      MessageBox(err);
      return;
    }
  }

}
//+------------------------------------------------------------------+
