//+------------------------------------------------------------------+
//|                                                       NN_Lib.mq4 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateATR(string pSymbol, datetime pTime, int pPeriod, int pATRPeriod, double pPercentCandleClosed)
  {
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
   return (NormalizeDouble(dATR,4));
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

struct struct_PositionSize
  {
   double  dPPositionSize;
   double Prize;
   double dStopLoss;
   double dTakeProfit;
   double dRiskMoney;
   int iLotDigits;
  };

struct_PositionSize CalculatePositionSize(string pSymbol, double pATR, double pAccountBalance, double pRisk, double pATRSLFactor, double pATRTPFactor, bool pBuy,
                             double pMODE_TICKSIZE, double pMODE_TICKVALUE, double pMODE_LOTSTEP, int pMODE_DIGITS, double pMODE_ASK, double pMODE_BID
                            )
  {
// double Size = AccountBalance(); // AccountEquity();
   double RiskMoney = pAccountBalance * pRisk / 100;
   int lotdigits     = - MathRound(MathLog(pMODE_LOTSTEP) / MathLog(10.0));
   double dStopLoss = pATRSLFactor * pATR;
   double dTP1 = pATRTPFactor * pATR;
   double PositionSize = 0;
   string sOrderKind = "buy";

   if((dStopLoss > 0) && (pMODE_TICKVALUE != 0) && (pMODE_TICKSIZE != 0))
      PositionSize = RiskMoney / (dStopLoss * pMODE_TICKVALUE / pMODE_TICKSIZE);

   double dNormalizedPositionSize = NormalizeDouble(PositionSize,lotdigits);

   double dPrice = pMODE_ASK;
   double dPrizeSL = dPrice-dStopLoss;
   double dPrizeTP1 = dPrice+dTP1;
   if(pBuy == false)
     {
      sOrderKind = "sell";
      dPrice = pMODE_BID;
      dPrizeSL = dPrice+dStopLoss;
      dPrizeTP1 = dPrice-dTP1;
     }
//Alert(pMODE_DIGITS);
   double dNormalizedPrizeSL = NormalizeDouble(dPrizeSL, pMODE_DIGITS);
   double dNormalizedPrizeTP1 = NormalizeDouble(dPrizeTP1, pMODE_DIGITS);

// Comment(sOrderKind, " ", _Symbol, "\n\rRisk in %: ", extRisk, "\n\rPrice: ", dPrice, "\n\rSL: ", DoubleToStr(dNormalizedPrizeSL,pMODE_DIGITS), "\n\rTP1: ", DoubleToStr(dNormalizedPrizeTP1,pMODE_DIGITS), "\n\rPosition-Size: ", DoubleToStr(dNormalizedPositionSize,lotdigits), "\n\rATR: ", pATR);
   //struct_PositionSize ps = {PositionSize, dPrizeSL, dPrizeTP1, RiskMoney};
   struct_PositionSize ps;
   ps.dPPositionSize = PositionSize;
   ps.Prize = dPrice;
   ps.dStopLoss = dPrizeSL;
   ps.dTakeProfit = dPrizeTP1;
   ps.dRiskMoney = RiskMoney;
   ps.iLotDigits = lotdigits;
   
   return ps;

  }
//+------------------------------------------------------------------+
