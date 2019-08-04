//+------------------------------------------------------------------+
//|                                                HCustomizados.mqh |
//|                            Copyright ® 2019, Hércules S. S. José |
//|                        https://www.linkedin.com/in/herculeshssj/ |
//+------------------------------------------------------------------+
#property copyright "Copyright ® 2019, Hércules S. S. José"
#property link      "https://www.linkedin.com/in/herculeshssj/"
#property description "Arquivo MQH que contém as estratégias para negociação utilizando indicadores customizados."

//--- Inclusão de arquivos
#include "..\\HStrategy.mqh"

//+------------------------------------------------------------------+
//| Classe CPriceChannel - Sinais de negociação baseado no indicador |
//| customizado Price Channel.                                       |
//+------------------------------------------------------------------+
class CPriceChannel : public CStrategy {

   private:
      int customHandle;

   public:
      //--- Métodos
      virtual int init(void);
      virtual void release(void);
      virtual int sinalNegociacao(void);
      virtual int sinalConfirmacao(int sinalNegociacao);
      virtual int sinalSaidaNegociacao(int chamadaSaida);  
      
      int onTickBarTimer(void) {
         return(1); // Nova barra
      }    

};

int CPriceChannel::init(void) {

   this.customHandle = iCustom(_Symbol, _Period, "Artigos\\PriceChannel", 22);
   
   //--- Verifica se os indicadores foram criados com sucesso
   if (this.customHandle < 0) {
      Alert("Erro ao criar o indicador! Erro ", GetLastError());
      return(INIT_FAILED);
   }
   
   //--- Retorna o sinal de sucesso
   return(INIT_SUCCEEDED);
   
}

void CPriceChannel::release(void) {
   //--- Libera os indicadores
   IndicatorRelease(this.customHandle);
}

int CPriceChannel::sinalNegociacao(void) {

   //--- Zero significa que não é pra abrir nenhum posição
   int sinal = 0;
   
   //--- Armazena os valores do indicador e o close das últimas barras
   double customBuffer1[], customBuffer2[], close[];
   
   //--- Copia os valores dos indicadores para seus respectivos buffers
   if (CopyBuffer(this.customHandle, 0, 0, 3, customBuffer1) < 3
      || CopyBuffer(this.customHandle, 1, 0, 3, customBuffer2) < 3
      || CopyClose(_Symbol, _Period, 0, 2, close) < 2) {
      Print("Falha ao copiar os dados dos indicadores para os buffers! Erro ", GetLastError());
      return(sinal);
   }
   
   //--- Define os buffers como série temporal
   if (!ArraySetAsSeries(customBuffer1, true) || !ArraySetAsSeries(customBuffer2, true)
      || !ArraySetAsSeries(close, true)) {
      Print("Falha ao definir o buffer como série temporal! Erro ", GetLastError());
      return(sinal);
   }
   
   //--- Verifica os dados do indicador para determinar o sinal de negociação
   if (close[1] > customBuffer1[2]) {
      sinal = 1;
   } else if (close[1] < customBuffer2[2]) {
      sinal = -1;
   } else {
      sinal = 0;
   }
      
   //--- Retorna o sinal de negociação
   return(sinal);
   
}

int CPriceChannel::sinalConfirmacao(int sinalNegociacao) {
   
   int sinal = sinalNegociacao;
   
   //--- Retorna o sinal de confirmação
   return(sinal);
   
}

int CPriceChannel::sinalSaidaNegociacao(int chamadaSaida) {
   return(-1);
}

//+------------------------------------------------------------------+

/* Desde ponto em diante ficam as declarações das classes das estratégias
   declaradas neste arquivo MQH
*/

//--- Declaração de classes
CPriceChannel cPriceChannel;

//+------------------------------------------------------------------+