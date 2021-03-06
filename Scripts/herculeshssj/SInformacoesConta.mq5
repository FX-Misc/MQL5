//+------------------------------------------------------------------+
//|                                            SInformacoesConta.mq5 |
//|                            Copyright ® 2019, Hércules S. S. José |
//|                        https://www.linkedin.com/in/herculeshssj/ |
//+------------------------------------------------------------------+
#property copyright "Copyright ® 2019, Hércules S. S. José"
#property link      "https://www.linkedin.com/in/herculeshssj/"
#property version   "1.00"
#property description "Script que mostra todas as informações sobre a conta selecionada."

#include <herculeshssj\HAccount.mqh>

CAccount cAccount;

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart() {

   //--- Obtenção dos valores de enums
   ENUM_ACCOUNT_TRADE_MODE accountTradeMode = (ENUM_ACCOUNT_TRADE_MODE)AccountInfoInteger(ACCOUNT_TRADE_MODE);
   ENUM_ACCOUNT_STOPOUT_MODE accountStopOutMode = (ENUM_ACCOUNT_STOPOUT_MODE)AccountInfoInteger(ACCOUNT_MARGIN_SO_MODE);
   ENUM_ACCOUNT_MARGIN_MODE accountMarginMode = (ENUM_ACCOUNT_MARGIN_MODE)AccountInfoInteger(ACCOUNT_MARGIN_MODE);
   bool thisAccountTradeAllowed = AccountInfoInteger(ACCOUNT_TRADE_ALLOWED);
   bool EATradeAllowed = AccountInfoInteger(ACCOUNT_TRADE_EXPERT);

   Print("***** INFORMAÇÕES GERAIS SOBRE A CONTA *****");
   
   //--- Exibe todas as informações disponíveis a partir da função AccountInfoString() 
   Print("Nome da corretora: ", AccountInfoString(ACCOUNT_COMPANY)); 
   Print("Moeda do depósito: ", AccountInfoString(ACCOUNT_CURRENCY)); 
   Print("Nome do cliente: ", AccountInfoString(ACCOUNT_NAME)); 
   Print("Nome do servidor comercial: ",AccountInfoString(ACCOUNT_SERVER)); 
   
   //--- Exibe todas as informações disponíveis a partir da função AccountInfoInteger()
   PrintFormat("Login (LOGIN): %d", AccountInfoInteger(ACCOUNT_LOGIN));
   PrintFormat("Alavancagem (LEVERAGE): 1:%I64d", AccountInfoInteger(ACCOUNT_LEVERAGE));
   switch(accountTradeMode) {
      case ACCOUNT_TRADE_MODE_REAL : PrintFormat("Modo de negociação da conta (TRADE_MODE): %s", "Conta real"); break;
      case ACCOUNT_TRADE_MODE_DEMO : PrintFormat("Modo de negociação da conta (TRADE_MODE): %s", "Conta demonstração"); break;
      case ACCOUNT_TRADE_MODE_CONTEST : PrintFormat("Modo de negociação da conta (TRADE_MODE): %s", "Conta competição/torneio"); break; 
   }
   PrintFormat("Número máximo de ordens pendentes (LIMIT_ORDERS): %d", AccountInfoInteger(ACCOUNT_LIMIT_ORDERS));
   switch(accountStopOutMode) {
      case ACCOUNT_STOPOUT_MODE_MONEY : PrintFormat("Modo da margem mínima permitida (MARGIN_SO_MODE): %s", "Dinheiro"); break;
      case ACCOUNT_STOPOUT_MODE_PERCENT : PrintFormat("Modo da margem mínima permitida (MARGIN_SO_MODE): %s", "Porcentagem"); break;
   }
   if (thisAccountTradeAllowed) {
      PrintFormat("Negociação permitida (TRADE_ALLOWED): %s", "Negociação permitida!");
   } else {
      PrintFormat("Negociação permitida (TRADE_ALLOWED): %s", "Negociação PROIBIDA!");
   }
   if (EATradeAllowed) {
      PrintFormat("Negociação permitida para Expert Advisor (TRADE_EXPERT): %s", "Negociação permitida para Expert Advisor!");
   } else {
      PrintFormat("Negociação permitida para Expert Advisor (TRADE_EXPERT): %s", "Negociação PROIBIDA para Expert Advisor!");
   }
   switch(accountMarginMode) {
      case ACCOUNT_MARGIN_MODE_EXCHANGE : PrintFormat("Modo de cálculo de margem (MARGIN_MODE): %s", "EXCHANGE"); break;
      case ACCOUNT_MARGIN_MODE_RETAIL_HEDGING : PrintFormat("Modo de cálculo de margem (MARGIN_MODE): %s", "RETAIL HEDGING"); break;
      case ACCOUNT_MARGIN_MODE_RETAIL_NETTING : PrintFormat("Modo de cálculo de margem (MARGIN_MODE): %s", "RETAIL NETTING"); break; 
   }
   PrintFormat("Número de casas decimais para a moeda da conta (CURRENCY_DIGITS): %d", AccountInfoInteger(ACCOUNT_CURRENCY_DIGITS));
   
   //--- Exibe todas as informações disponíveis a partir da função AccountInfoDouble()
   PrintFormat("Saldo da conta (BALANCE): %G", AccountInfoDouble(ACCOUNT_BALANCE));
   PrintFormat("Crédito da conta (CREDIT): %G", AccountInfoDouble(ACCOUNT_CREDIT));
   PrintFormat("Lucro atual (PROFIT): %G", AccountInfoDouble(ACCOUNT_PROFIT));
   PrintFormat("Saldo a mercado (EQUITY): %G", AccountInfoDouble(ACCOUNT_EQUITY));
   PrintFormat("Margem usada (MARGIN): %G", AccountInfoDouble(ACCOUNT_MARGIN));
   PrintFormat("Margem livre (MARGIN_FREE): %G", AccountInfoDouble(ACCOUNT_MARGIN_FREE));
   PrintFormat("Nível de margem (MARGIN_LEVEL): %G %s", AccountInfoDouble(ACCOUNT_MARGIN_LEVEL), "%");
   switch(accountStopOutMode) {
      case ACCOUNT_STOPOUT_MODE_MONEY : PrintFormat("Nível de chamada de margem (MARGIN_SO_CALL): %G", AccountInfoDouble(ACCOUNT_MARGIN_SO_CALL)); break;
      case ACCOUNT_STOPOUT_MODE_PERCENT : PrintFormat("Nível de chamada de margem (MARGIN_SO_CALL): %G %s", AccountInfoDouble(ACCOUNT_MARGIN_SO_CALL), "%"); break;
   }
   switch(accountStopOutMode) {
      case ACCOUNT_STOPOUT_MODE_MONEY : PrintFormat("Nível de margem de Stop Out - encerramento forçado (MARGIN_SO_SO): %G", AccountInfoDouble(ACCOUNT_MARGIN_SO_SO)); break;
      case ACCOUNT_STOPOUT_MODE_PERCENT : PrintFormat("Nível de margem de Stop Out - encerramento forçado (MARGIN_SO_SO): %G %s", AccountInfoDouble(ACCOUNT_MARGIN_SO_SO), "%"); break;
   }
   PrintFormat("Margem inicial (MARGIN_INITIAL): %G", AccountInfoDouble(ACCOUNT_MARGIN_INITIAL));
   PrintFormat("Margem de manutenção (MARGIN_MAINTENANCE): %G", AccountInfoDouble(ACCOUNT_MARGIN_MAINTENANCE));
   PrintFormat("Ativos atuais (ASSETS): %G", AccountInfoDouble(ACCOUNT_ASSETS));
   PrintFormat("Responsabilidades atuais (LIABILITIES): %G", AccountInfoDouble(ACCOUNT_LIABILITIES));
   PrintFormat("Comissão bloqueada (COMMISION_BLOCKED): %G", AccountInfoDouble(ACCOUNT_COMMISSION_BLOCKED));
      
   Print("***** FIM DO RELATÓRIO *****");   
   
}
//+------------------------------------------------------------------+
