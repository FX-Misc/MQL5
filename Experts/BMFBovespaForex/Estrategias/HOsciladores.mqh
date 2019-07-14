//+------------------------------------------------------------------+
//|                                                 HOsciladores.mqh |
//|                            Copyright ® 2019, Hércules S. S. José |
//|                        https://www.linkedin.com/in/herculeshssj/ |
//+------------------------------------------------------------------+
#property copyright "Copyright ® 2019, Hércules S. S. José"
#property link      "https://www.linkedin.com/in/herculeshssj/"
#property description "Arquivo MQH que contém as estratégias para negociação utilizando osciladores."

//--- Inclusão de arquivos
#include "..\\HStrategy.mqh"

//+------------------------------------------------------------------+
//| Classe CSinalMACD - Sinais de negociação baseado no oscilador    |
//| MACD                                                             |
//+------------------------------------------------------------------+
class CSinalMACD : public CStrategy {

   private:
      int macdHandle;

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

int CSinalMACD::init(void) {

   this.macdHandle = iMACD(_Symbol, _Period, 12, 26, 9, PRICE_CLOSE);
   
   //--- Verifica se os indicadores foram criados com sucesso
   if (this.macdHandle < 0) {
      Alert("Erro ao criar o indicador! Erro ", GetLastError());
      return(INIT_FAILED);
   }
   
   //--- Retorna o sinal de sucesso
   return(INIT_SUCCEEDED);
   
}

void CSinalMACD::release(void) {
   //--- Libera os indicadores
   IndicatorRelease(this.macdHandle);
}

int CSinalMACD::sinalNegociacao(void) {

   //--- Zero significa que não é pra abrir nenhum posição
   int sinal = 0;
   
   double macdBuffer[], signalBuffer[]; // Armazena os valores do oscilador MACD
   
   //--- Copia o valor do indicador para seu respectivo buffer
   if (CopyBuffer(this.macdHandle, 0, 0, 2, macdBuffer) < 2
      || CopyBuffer(this.macdHandle, 1, 0, 3, signalBuffer) < 3) {
      Print("Falha ao copiar dados do indicador para o buffer! Erro ", GetLastError());
      return(sinal);
   }
   
   //--- Define os buffers como série temporal
   if (!ArraySetAsSeries(macdBuffer, true) || !ArraySetAsSeries(signalBuffer, true)) {
      Print("Falha ao definir o buffer como série temporal! Erro ", GetLastError());
      return(sinal);
   }
   
   //--- perform checking of the condition and set the value for sig
   if (signalBuffer[2] > macdBuffer[1] && signalBuffer[1] < macdBuffer[1]) {
      sinal = 1;
   } else if (signalBuffer[2] < macdBuffer[1] && signalBuffer[1] > macdBuffer[1]) {
      sinal = -1;
   } else {
      sinal = 0;
   }
   
   //--- Retorna o sinal de negociação
   return(sinal);
   
}

int CSinalMACD::sinalConfirmacao(int sinalNegociacao) {
   
   int sinal = sinalNegociacao;
   
   //--- Retorna o sinal de confirmação
   return(sinal);
   
}

int CSinalMACD::sinalSaidaNegociacao(int chamadaSaida) {
   return(-1);
}

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Classe CSinalEstocastico - Sinais de negociação baseado no       |
//| oscilador Estocástico                                            |
//+------------------------------------------------------------------+
class CSinalEstocastico : public CStrategy {

   private:
      int estocasticoHandle;

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

int CSinalEstocastico::init(void) {

   estocasticoHandle = iStochastic(_Symbol, _Period, 5, 3, 3, MODE_SMA, STO_LOWHIGH);
   
   //--- Verifica se os indicadores foram criados com sucesso
   if (estocasticoHandle < 0) {
      Alert("Erro ao criar o indicador! Erro ", GetLastError());
      return(INIT_FAILED);
   }
   
   //--- Retorna o sinal de sucesso
   return(INIT_SUCCEEDED);
   
}

void CSinalEstocastico::release(void) {
   //--- Libera os indicadores
   IndicatorRelease(estocasticoHandle);
}

int CSinalEstocastico::sinalNegociacao(void) {

   //--- Zero significa que não é pra abrir nenhum posição
   int sinal = 0;
   
   double estocasticoBuffer[]; // Armazena os valores do oscilador estocástico
   
   //--- Copia o valor do indicador para seu respectivo buffer
   if (CopyBuffer(estocasticoHandle, 0, 0, 3, estocasticoBuffer) < 3) {
      Print("Falha ao copiar dados do indicador para o buffer! Erro ", GetLastError());
      return(sinal);
   }
   
   //--- Define os buffers como série temporal
   if (!ArraySetAsSeries(estocasticoBuffer, true)) {
      Print("Falha ao definir o buffer como série temporal! Erro ", GetLastError());
      return(sinal);
   }
   
   //--- perform checking of the condition and set the value for sig
   if (estocasticoBuffer[2] < 20 && estocasticoBuffer[1] > 20) {
      sinal = 1;
   } else if (estocasticoBuffer[2] > 80 && estocasticoBuffer[1] < 80) {
      sinal = -1;
   } else {
      sinal = 0;
   }
   
   //--- Retorna o sinal de negociação
   return(sinal);
   
}

int CSinalEstocastico::sinalConfirmacao(int sinalNegociacao) {
   
   int sinal = sinalNegociacao;
   
   //--- Retorna o sinal de confirmação
   return(sinal);
   
}

int CSinalEstocastico::sinalSaidaNegociacao(int chamadaSaida) {
   return(-1);
}

//+------------------------------------------------------------------+

/* Desde ponto em diante ficam as declarações das classes das estratégias
   declaradas neste arquivo MQH
*/

//--- Declaração de classes
CSinalMACD cSinalMACD;
CSinalEstocastico cSinalEstocastico;

//+------------------------------------------------------------------+