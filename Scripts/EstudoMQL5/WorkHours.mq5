//+------------------------------------------------------------------+
//|                                                    WorkHours.mq5 |
//|                              Copyright 2019, Hércules S. S. José |
//|                        https://www.linkedin.com/in/herculeshssj/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Hércules S. S. José"
#property link      "https://www.linkedin.com/in/herculeshssj/"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
//--- set 1 for working hours and 0 for nonworking ones 
   int AsianSession=B'111111111'; // Asian session from 0:00 to 9:00 
   int EuropeanSession=B'111111111000000000'; // European session 9:00 - 18:00 
   int AmericanSession=B'111111110000000000000011'; // American session 16:00 - 02:00 
//--- derive numerical values of the sessions 
   PrintFormat("Asian session hours as value =%d",AsianSession);
   PrintFormat("European session hours as value is %d",EuropeanSession);
   PrintFormat("American session hours as value is %d",AmericanSession);
//--- and now let's display string representations of the sessions' working hours 
   Print("Asian session ",GetHoursForSession(AsianSession));
   Print("European session ",GetHoursForSession(EuropeanSession));
   Print("American session ",GetHoursForSession(AmericanSession));
//--- 

  }
//+------------------------------------------------------------------+ 
//| return the session's working hours as a string                   | 
//+------------------------------------------------------------------+ 
string GetHoursForSession(int session)
  {
//--- in order to check, use AND bit operations and left shift by 1 bit <<=1 
//--- start checking from the lowest bit 
   int bit=1;
   string out="working hours: ";
//--- check all 24 bits starting from the zero one and up to 23 inclusively   
   for(int i = 0; i < 24; i++)
     {
      //--- receive bit state in number 
      bool workinghour = (session&bit) == bit;
      //--- add the hour's number to the message 
      if(workinghour)out=out+StringFormat("%d ",i);
      //--- shift by one bit to the left to check the value of the next one 
      bit<<=1;
     }
//--- result string 
   return out;
  }
//+------------------------------------------------------------------+
