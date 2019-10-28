#property strict
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+

#include "NN_Lib.mqh"

int errors = 0;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnInit()
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
void OnDeinit(const int reason)
  {
    if (errors == 0) Print("No errors!"); else Print(errors, " errors occured");
  }
//+------------------------------------------------------------------+
