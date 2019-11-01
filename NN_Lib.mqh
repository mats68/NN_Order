//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "M. Thaler"
#property version   "1.00"
#property strict

#include <stdlib.mqh>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateATR(string pSymbol, datetime pTime, int pPeriod, int pATRPeriod, double pPercentCandleClosed) {
  int bar = iBarShift(pSymbol,pPeriod,pTime);
  if(bar == -1)
    return -1;
  double dPeriod = pPeriod*60;
  double dLeftTime = dPeriod-(pTime-iTime(pSymbol,pPeriod,bar));
  double iPercentCandleClosed = (dPeriod-dLeftTime)*100/dPeriod;
  int iShift = bar;
  if(iPercentCandleClosed < pPercentCandleClosed)
    iShift++;
  double dATR = iATR(pSymbol,pPeriod,pATRPeriod,iShift);
  return dATR;
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

struct struct_PositionSize {
  double            dPositionSize;
  double            Prize;
  double            dStopLoss;
  double            dTakeProfit;
  double            dRiskMoney;
  int               iLotDigits;
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct_PositionSize CalculatePositionSize(string pSymbol, double pATR, double pAccountBalance, double pRisk, double pATRSLFactor, double pATRTPFactor, bool pBuy,
    double pTICKSIZE, double pTICKVALUE, double pLOTSTEP, int pDIGITS, double pASK, double pBID
                                         ) {
  double RiskMoney = pAccountBalance * pRisk / 100;
  int lotdigits     = - MathRound(MathLog(pLOTSTEP) / MathLog(10.0));
  double dStopLoss = pATRSLFactor * pATR;
  double dTP1 = pATRTPFactor * pATR;
  double PositionSize = 0;
  string sOrderKind = "buy";

  if((dStopLoss > 0) && (pTICKVALUE != 0) && (pTICKSIZE != 0))
    PositionSize = RiskMoney / (dStopLoss * pTICKVALUE / pTICKSIZE);

  double dNormalizedPositionSize = NormalizeDouble(PositionSize,lotdigits);

  double dPrice = pASK;
  double dPrizeSL = dPrice-dStopLoss;
  double dPrizeTP1 = dPrice+dTP1;
  if(pBuy == false) {
    sOrderKind = "sell";
    dPrice = pBID;
    dPrizeSL = dPrice+dStopLoss;
    dPrizeTP1 = dPrice-dTP1;
  }
  double dNormalizedPrizeSL = NormalizeDouble(dPrizeSL, pDIGITS);
  double dNormalizedPrizeTP1 = NormalizeDouble(dPrizeTP1, pDIGITS);

  struct_PositionSize ps;
  ps.dPositionSize = dNormalizedPositionSize;
  ps.Prize = dPrice;
  ps.dStopLoss = dPrizeSL;
  ps.dTakeProfit = dPrizeTP1;
  ps.dRiskMoney = RiskMoney;
  ps.iLotDigits = lotdigits;

  return ps;

}
//+------------------------------------------------------------------+

//double NormalizeEntrySize(double size)
//{
//    double minlot  = MarketInfo(_Symbol, MODE_MINLOT);
//    double lotstep = MarketInfo(_Symbol, MODE_LOTSTEP);
//
//    if (size <= minlot)
//        return (minlot);
//
//    int steps = (int) MathRound((size - minlot) / lotstep);
//    size = minlot + steps * lotstep;
//
//    if (size >= Maximum_Lots)
//        size = Maximum_Lots;
//
//    size = NormalizeDouble(size, digits);
//
//    return (size);
//}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool HasOpenTradesForSymbol(string sOrderSymbol) {

  int itotal=OrdersTotal();

  for(int i=0; i<itotal; i++) { // for loop
    if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == true)
      // check for opened position symbol
      if(OrderSymbol()== sOrderSymbol)
        return true;
  }

  return false;
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string LaunchTrade(
  string   pSymbol,              // symbol
  int      pCmd,                 // operation
  double   pVolume,              // volume
  double   pPrice,               // price
  int      pSlippage,            // slippage
  double   pStoploss,            // stop loss
  double   pTakeprofit,          // take profit
  string   pComment=NULL        // comment
) {

  int ticket = OrderSend(pSymbol,pCmd,pVolume,pPrice,pSlippage,pStoploss,pTakeprofit,pComment);
  if(ticket<0) {
    int err = GetLastError();
    if(err != ERR_NO_ERROR)
      return("Error Nr." +  IntegerToString(err) + ": " + ErrorDescription(err));
    else
      return ("");

  }
  return ("");
}
//+------------------------------------------------------------------+
