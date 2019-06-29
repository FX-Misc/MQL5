//+------------------------------------------------------------------+
//|                                                       HMoney.mqh |
//|                            Copyright ® 2019, Hércules S. S. José |
//|                        https://www.linkedin.com/in/herculeshssj/ |
//+------------------------------------------------------------------+
#property copyright "Copyright ® 2019, Hércules S. S. José"
#property link      "https://www.linkedin.com/in/herculeshssj/"
#property description "Classe com métodos utilitários para gerenciamento financeiro da conta."

//--- Inclusão de arquivos
#include "HAccount.mqh"

//--- Declaração de classes
CAccount cAccount; // Classe com métodos para obter informações sobre a conta

//+------------------------------------------------------------------+
//| Classe CMoney - responsável por gerenciar os recursos financeiros|
//| disponíveis na conta.                                            |
//+------------------------------------------------------------------+
class CMoney {
      
   public:
      //--- Atributos
      double lucroGarantido;
      
      //--- Métodos
      void CMoney() {};            // Construtor
      void ~CMoney() {};           // Construtor
      bool atingiuLucroDesejado();
};

//+------------------------------------------------------------------+
//| Retorna true quando o lucro das posições abertas atingir o lucro |
//| alvo desejado. O valor alvo é proporcional ao tamanho da margem  |
//| para abertura da posição para o símbolo atual.                   |
//+------------------------------------------------------------------+
bool CMoney::atingiuLucroDesejado(void) {

   for (int i = PositionsTotal() - 1; i >= 0; i--) {
      if (PositionSelectByTicket(PositionGetTicket(i)) && PositionGetString(POSITION_SYMBOL) == _Symbol) {
         
         double lucro = PositionGetDouble(POSITION_PROFIT);
         double valorAlvo = cAccount
            .obterMargemNecessariaParaNovaPosicao(PositionGetDouble(POSITION_VOLUME), 
               (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE))
            * 0.2; // 20% da margem disponível para abertura
         
         if (lucro > valorAlvo) {
            
            //--- Se o lucro garantido está sendo definido pela primeira vez, o lucro atual será o lucro garantido
            if (this.lucroGarantido == 0) {
               this.lucroGarantido = lucro;
            } else {
               //--- Verifica se o lucro ultrapassou 20% do lucro garantido
               if ( lucro > (this.lucroGarantido * 1.2) ) {
                  //--- Define o novo lucro garantido
                  this.lucroGarantido = lucro;                  
                  
               } else if (lucro <= (lucroGarantido * 0.8) ) {
                  // Reseta as variáveis
                  this.lucroGarantido = 0;
               
                  //--- Retorna true informando que o lucro desejado foi atingido
                  return(true);
               
               }
            }
            
         } 
      }         
   }
   
   return(false);
}
//+------------------------------------------------------------------+