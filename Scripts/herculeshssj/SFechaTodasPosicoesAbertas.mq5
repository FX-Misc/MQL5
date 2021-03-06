//+------------------------------------------------------------------+
//|                                      FechaTudo_e_VaiPraPraia.mq5 |
//|                            Copyright ® 2019, Hércules S. S. José |
//|                        https://www.linkedin.com/in/herculeshssj/ |
//+------------------------------------------------------------------+
#property copyright "Copyright ® 2019, Hércules S. S. José"
#property link      "https://www.linkedin.com/in/herculeshssj/"
#property version   "1.00"
#property description "Script que encerra todas as posições abertas e exclui todas as ordens pendentes para o gráfico atual."

#include <Trade\Trade.mqh>

CTrade cTrade;
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   
   //-- Exclui todas as ordens pendentes
   for (int i = OrdersTotal() - 1; i >= 0; i--) {
      cTrade.OrderDelete(OrderGetTicket(i));
   }
   
   //-- Fecha todas as posições abertas
   for (int i = PositionsTotal() - 1; i >= 0; i--) {
      cTrade.PositionClose(PositionGetTicket(i));
   }
   
  }
//+------------------------------------------------------------------+
