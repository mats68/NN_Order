//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property strict
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+

#include "NN_Lib.mqh"

int errors = 0;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnStart()
  {
   string sSymbol = "EURUSD";
   datetime dDate = D'2019.10.01 23:46:58';
   int iPeriod = PERIOD_D1;
   int iATRPeriod = 14;
   double dPercentCandleClosed = 98;
   TestATR(0.0071,sSymbol,dDate,iPeriod, iATRPeriod, dPercentCandleClosed);
   dDate = D'2019.10.01 12:46:58';
   TestATR(0.0072,sSymbol,dDate,iPeriod, iATRPeriod, dPercentCandleClosed);
   dDate = D'2019.09.25 23:40:10';
   TestATR(0.0068,sSymbol,dDate,iPeriod, iATRPeriod, dPercentCandleClosed);
   dDate = D'2019.09.25 22:40:10';
   TestATR(0.0067,sSymbol,dDate,iPeriod, iATRPeriod, dPercentCandleClosed);


   sSymbol = "GOLD";
   dDate = D'2019.10.28 17:18:10';
   iPeriod = PERIOD_D1;
   iATRPeriod = 14;
   dPercentCandleClosed = 98;
   double dAccountBalance = 99687.59;
   double dRisk = 1;
   double dATRSLFactor = 1.5;
   double dATRTPFactor = 1;
   bool bBuy = false;
   double dBID = 1490.7;
   double dASK = 1491;
   double dDIGITS = 1.0;
   double dLOTSTEP = 0.01;
   double dTICKVALUE = 0.9012744020044343;
   double dTICKSIZE = 0.1;

 //Print("MODE_TICKSIZE: ",MarketInfo(sSymbol, MODE_TICKSIZE));
 //Print("MODE_TICKVALUE: ",MarketInfo(sSymbol, MODE_TICKVALUE));
 //Print("MODE_LOTSTEP: ",MarketInfo(sSymbol,MODE_LOTSTEP));
 //Print("MODE_DIGITS: ",MarketInfo(sSymbol,MODE_DIGITS));
 //Print("MODE_ASK: ",MarketInfo(sSymbol,MODE_ASK));
 //Print("MODE_BID: ",MarketInfo(sSymbol,MODE_BID));



   struct_PositionSize ps;
   TestPositionSize(ps,dDate,iPeriod, iATRPeriod, dPercentCandleClosed,
   sSymbol, dAccountBalance, dRisk, dATRSLFactor, dATRTPFactor, bBuy, dTICKSIZE, dTICKVALUE, dLOTSTEP, dDIGITS, dASK, dBID);


  //  ps.dPPositionSize = dNormalizedPositionSize;
  //  ps.Prize = dPrice;
  //  ps.dStopLoss = dPrizeSL;
  //  ps.dTakeProfit = dPrizeTP1;
  //  ps.dRiskMoney = RiskMoney;
  //  ps.iLotDigits = lotdigits;



  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TestATR(double pExpVal,string pSymbol, datetime pDate, int pPeriod, int pATRPeriod, double pPercentCandleClosed)
  {
   double val = CalculateATR(pSymbol, pDate, pPeriod, pATRPeriod, pPercentCandleClosed);
   if(val != pExpVal)
     {
      Print("Error in CalculateATR: ", " Expected Value: ", pExpVal, " got Value: ", val);
      Print("Symbol: ", pSymbol, " Date: ", pDate, " Period: ", pPeriod);
      errors++;
     }

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TestPositionSize(struct_PositionSize &pExpVal,
                      datetime pDate, int pPeriod, int pATRPeriod, double pPercentCandleClosed,
                      string pSymbol, double pAccountBalance, double pRisk, double pATRSLFactor, double pATRTPFactor, bool pBuy,
                      double pTICKSIZE, double pTICKVALUE, double pLOTSTEP, int pDIGITS, double pASK, double pBID)
  {
   double dATR = CalculateATR(pSymbol, pDate, pPeriod, pATRPeriod, pPercentCandleClosed);
   struct_PositionSize ps = CalculatePositionSize(pSymbol, dATR, pAccountBalance, pRisk, pATRSLFactor, pATRTPFactor, pBuy,
                            pTICKSIZE, pTICKVALUE, pLOTSTEP, pDIGITS, pASK, pBID);

   Print("Symbol: ", pSymbol);
   Print("PositionSize: ", ps.dPositionSize);
   Print("Prize: ", ps.Prize);
   Print("dStopLoss: ", ps.dStopLoss);
   Print("dTakeProfit: ", ps.dTakeProfit);
   Print("Risk %: ", pRisk);

  }


//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(errors == 0)
      Print("No errors!");
   else
      Print(errors, " errors occured");
  }
//+------------------------------------------------------------------+
