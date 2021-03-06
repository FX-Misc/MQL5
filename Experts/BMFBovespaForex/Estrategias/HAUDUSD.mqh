//+------------------------------------------------------------------+
//|                                                       HForex.mqh |
//|                       Copyright ® 2019-2020, Hércules S. S. José |
//|                        https://www.linkedin.com/in/herculeshssj/ |
//+------------------------------------------------------------------+
#property copyright "Copyright ® 2019-2020, Hércules S. S. José"
#property link      "https://www.linkedin.com/in/herculeshssj/"
#property description "Arquivo MQH que contém a estratégia para negociação no mercado Forex com o par AUDUSD"

//--- Inclusão de arquivos
#include "..\\HStrategy.mqh"

//+------------------------------------------------------------------+
//| Classe CAUDUSD - Cruzamento Médias Móveis MA Curta de 20         |
//| períodos, MA Ágil de 5 períodos. Estratégia montada especifica-  |
//| mente para operar com o ativo AUDUSD.                            |
//+------------------------------------------------------------------+
class CAUDUSD : public CStrategy {

   private:
      //--- Atributos
      int maAgilHandle;
      int maCurtaHandle;

   public:
      //--- Métodos
      virtual int init(void);
      virtual void release(void);
      virtual int sinalNegociacao(void);
      virtual int sinalConfirmacao(int sinalNegociacao);
      virtual int sinalSaidaNegociacao(int chamadaSaida);
      virtual double obterStopLoss(ENUM_ORDER_TYPE tipoOrdem, double preco);
      virtual double obterTakeProfit(ENUM_ORDER_TYPE tipoOrdem, double preco);
      virtual void notificarUsuario(int sinalChamada);
};

int CAUDUSD::init(void) {
   
   //--- Inicializa os indicadores
   maAgilHandle = iMA(_Symbol, _Period, 5, 0, MODE_EMA, PRICE_CLOSE);
   maCurtaHandle = iMA(_Symbol, _Period, 20, 0, MODE_EMA, PRICE_CLOSE);
   
   //--- Verifica se os indicadores foram criados com sucesso
   if (maAgilHandle == INVALID_HANDLE 
      || maCurtaHandle == INVALID_HANDLE) {
      Alert("Erro ao criar os indicadores! Erro ", GetLastError());
      return(INIT_FAILED);
   }
         
   //--- Retorna o sinal de sucesso
   return(INIT_SUCCEEDED);
}

void CAUDUSD::release(void) {
   //--- Libera os indicadores
   IndicatorRelease(this.maAgilHandle);
   IndicatorRelease(this.maCurtaHandle);
}

int CAUDUSD::sinalNegociacao(void) {
   
   //--- Zero significa que não é pra abrir nenhum posição
   int sinal = 0;
   
   double maAgilBuffer[], maCurtaBuffer[]; // Armazena os valores das médias móveis
   
   //--- Copia o valor dos indicadores para seus respectivos buffers
   if (CopyBuffer(maAgilHandle, 0, 0, 3, maAgilBuffer) < 3
         || CopyBuffer(maCurtaHandle, 0, 0, 3, maCurtaBuffer) < 3) {
      Print("Falha ao copiar dados do indicador para o buffer! Erro ", GetLastError());
      return(sinal);
   }
   
   //--- Define os buffers como série temporal
   if (!ArraySetAsSeries(maAgilBuffer, true) 
      || !ArraySetAsSeries(maCurtaBuffer, true)) {
      Print("Falha ao definir os buffers como série temporal! Erro ", GetLastError());
      return(sinal);
   }
   
   //--- Verifica a MA das barras para determinar a tendência
   if (maAgilBuffer[2] < maCurtaBuffer[1] && maAgilBuffer[1] > maCurtaBuffer[1]) {
      // Tendência em alta
      sinal = 1;
   } else if (maAgilBuffer[2] > maCurtaBuffer[1] && maAgilBuffer[1] < maCurtaBuffer[1]) {
      // Tendência em baixa
      sinal = -1;
   } else {
      // Sem tendência
      sinal = 0;
   }
   
   //--- Retorna o sinal de negociação
   return(sinal);
   
}

int CAUDUSD::sinalConfirmacao(int sinalNegociacao) {
   
   //--- Zero significa que não é pra abrir nenhum posição
   //int sinal = 0;
   int sinal = sinalNegociacao;
   
   //--- Compara o sinal de negociação com o valor atual de suporte e resistência
   //--- do indicador NRTR
   
   /*
   //--- Tendência está a favor?
   if (sinalNegociacao == 1 && trailingStop.trend() == 1) {
      //--- Confirmado o sinal de compra
      sinal = 1;
   } else if (sinalNegociacao == -1 && trailingStop.trend() == -1) {
      //--- Confirmado o sinal de venda
      sinal = -1;
   }
   */
   
   //--- Retorna o sinal de confirmação
   return(sinal);
   
}

int CAUDUSD::sinalSaidaNegociacao(int chamadaSaida) {

   //--- Verifica se a chamada veio do método OnTimer()
   if (chamadaSaida == 9) {
      //--- Verifica se o ativo atingiu o lucro desejado para poder encerrar a posição
      if (cMoney.atingiuLucroDesejado()) {
         return(0); // Pode encerrar as posições abertas
      }
   }

   //--- Verifica o tamanho do prejuízo para poder encerrar as posições
   for (int i = PositionsTotal() - 1; i >= 0; i--) {
      if (PositionSelectByTicket(PositionGetTicket(i)) && PositionGetString(POSITION_SYMBOL) == _Symbol) {
         double lucro = PositionGetDouble(POSITION_PROFIT);
         if (lucro <= -30) { // Valores válidos: 30 ou 60. Deixando 30 pra evitar zerar o saldo
            //--- Encerra a posição quando o prejuízo alcançar o limite máximo estabelecido
            return(0); // Pode encerrar as posições abertas
         }
      }
   }

   return(-1);
}

double CAUDUSD::obterStopLoss(ENUM_ORDER_TYPE tipoOrdem, double preco) {
   return(0);
}

double CAUDUSD::obterTakeProfit(ENUM_ORDER_TYPE tipoOrdem, double preco) {
   return(0);
}

void CAUDUSD::notificarUsuario(int sinalChamada) {
   // Nenhuma notificação é enviada para o usuário
}

//+------------------------------------------------------------------+

/* Desde ponto em diante ficam as declarações das classes das estratégias
   declaradas neste arquivo MQH
*/

//--- Declaração de classes
CAUDUSD cAUDUSD;

//+------------------------------------------------------------------+