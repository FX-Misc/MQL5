//+------------------------------------------------------------------+
//|                                                   HTendencia.mqh |
//|                            Copyright ® 2019, Hércules S. S. José |
//|                        https://www.linkedin.com/in/herculeshssj/ |
//+------------------------------------------------------------------+
#property copyright "Copyright ® 2019, Hércules S. S. José"
#property link      "https://www.linkedin.com/in/herculeshssj/"
#property description "Arquivo MQH que contém as estratégias para negociação utilizando indicadores de tendência."

//--- Inclusão de arquivos
#include "..\\HStrategy.mqh"

//+------------------------------------------------------------------+
//| Classe CAdxMA - Sinais de negociação baseado no indicador ADX e  |
//| com confirmação de tendência a partir de uma MA exponencial.     |
//+------------------------------------------------------------------+
class CAdxMA : public CStrategy {

   private:
      int adxHandle;
      int maHandle;

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

int CAdxMA::init(void) {

   //--- Inicializa o indicador ADX
   this.adxHandle = iADX(_Symbol, 0, 8); // Período ADX = 8
   
   //--- Inicializa o indicador MA
   this.maHandle = iMA(_Symbol, _Period, 8, 0, MODE_EMA, PRICE_CLOSE); // Período MA = 8

   //--- Verifica se os indicadores foram criados com sucesso
   if (this.adxHandle < 0 || this.maHandle < 0) {
      Alert("Erro ao criar o indicador! Erro ", GetLastError());
      return(INIT_FAILED);
   }
   
   //--- Retorna o sinal de sucesso
   return(INIT_SUCCEEDED);
   
}

void CAdxMA::release(void) {
   //--- Libera os indicadores
   IndicatorRelease(this.adxHandle);
   IndicatorRelease(this.maHandle);
}

int CAdxMA::sinalNegociacao(void) {

   //--- Zero significa que não é pra abrir nenhum posição
   int sinal = 0;
   
   //--- Armazena os valores dos indicadores ADX e MA
   double plusDI[], minusDI[], adxValue[], maValue[];
   
   //--- Armazena as informações de cada barra
   MqlRates tradeRate[];
   
   //--- Copia os valores dos indicadores para seus respectivos buffers
   if (CopyBuffer(this.adxHandle, 0, 0, 3, adxValue) < 0
      || CopyBuffer(this.adxHandle, 1, 0, 3, plusDI) < 0
      || CopyBuffer(this.adxHandle, 2, 0, 3, minusDI) < 0
      || CopyBuffer(this.maHandle, 0, 0, 3, maValue) < 0
      || CopyRates(_Symbol, _Period, 0, 3, tradeRate) < 0) {
      Print("Falha ao copiar os dados dos indicadores para os buffers! Erro ", GetLastError());
      return(sinal);
   }
   
   //--- Define os buffers como série temporal
   if (!ArraySetAsSeries(adxValue, true) || !ArraySetAsSeries(maValue, true)
      || !ArraySetAsSeries(plusDI, true) || !ArraySetAsSeries(minusDI, true)) {
      Print("Falha ao definir o buffer como série temporal! Erro ", GetLastError());
      return(sinal);
   }
   
   //--- A partir dos valores obtidos dos indicadores, determina se temos um sinal de compra
   bool buyCondition1 = (maValue[0] > maValue[1]) && (maValue[1] > maValue[2]); // MA-8 Increasing upwards
   bool buyCondition2 = (tradeRate[1].close > maValue[1]); // previous price closed above MA-8
   bool buyCondition3 = (adxValue[0] > 22); // Current ADX value greater than minimun value (22)
   bool buyCondition4 = (plusDI[0] > minusDI[0]); // +DI greater than -DI
   
   //--- Put all together
   if (buyCondition1 && buyCondition2) {
      if (buyCondition3 && buyCondition4) {
         //-- Sinal de compra
         sinal = 1;
      }
   }
   
   //--- A partir dos valores obtidos dos indicadores, determina se termos um sinal de venda
   bool sellCondition1 = (maValue[0] < maValue[1]) && (maValue[1] < maValue[2]); // MA-8 Decreasing downwards
   bool sellCondition2 = (tradeRate[1].close < maValue[1]); // previous price closed below MA-8
   bool sellCondition3 = (adxValue[0] > 22); // Current ADX value greater than minimun value (22)
   bool sellCondition4 = (plusDI[0] < minusDI[0]); // -DI greater than +DI
   
   //--- Put all together
   if (sellCondition1 && sellCondition2) {
      if (sellCondition3 && sellCondition4) {
         sinal = -1;
      }
   }
   
   //--- Retorna o sinal de negociação
   return(sinal);
   
}

int CAdxMA::sinalConfirmacao(int sinalNegociacao) {
   
   //--- O sinal é passado direto, uma vez que todas as condições de entrada na 
   //--- negociação foram previamente atendidas.
   int sinal = sinalNegociacao;
   
   //--- Retorna o sinal de confirmação
   return(sinal);
   
}

int CAdxMA::sinalSaidaNegociacao(int chamadaSaida) {
   return(-1);
}

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Classe CBollingerBands - Sinais de negociação baseado na ruptura |
//| das bordas de Bollinger.                                         |
//+------------------------------------------------------------------+
class CBollingerBands : public CStrategy {

   private:
      int bollingerHandle;
      
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

int CBollingerBands::init(void) {

   //--- Inicializa o indicador Bollinger
   this.bollingerHandle = iBands(_Symbol, _Period, 20, 0, 2, PRICE_CLOSE);
   
   //--- Verifica se os indicadores foram criados com sucesso
   if (this.bollingerHandle < 0) {
      Alert("Erro ao criar o indicador! Erro ", GetLastError());
      return(INIT_FAILED);
   }
   
   //--- Retorna o sinal de sucesso
   return(INIT_SUCCEEDED);
   
}

void CBollingerBands::release(void) {
   //--- Libera os indicadores
   IndicatorRelease(this.bollingerHandle);
}

int CBollingerBands::sinalNegociacao(void) {

   //--- Zero significa que não é pra abrir nenhum posição
   int sinal = 0;
   
   //-- Armaze os valores do indicador Bollinger e do close das últimas barras
   double bollingerBuffer1[], bollingerBuffer2[], close[];
   
   //--- Copia os valores dos indicadores para seus respectivos buffers
   if (CopyBuffer(this.bollingerHandle, 1, 0, 2, bollingerBuffer1) < 2
      || CopyBuffer(this.bollingerHandle, 2, 0, 2, bollingerBuffer2) < 2
      || CopyClose(_Symbol, _Period, 0, 3, close) < 3) {
      Print("Falha ao copiar os dados dos indicadores para os buffers! Erro ", GetLastError());
      return(sinal);
   }
   
   //--- Define os buffers como série temporal
   if (!ArraySetAsSeries(bollingerBuffer1, true) || !ArraySetAsSeries(bollingerBuffer2, true)
      || !ArraySetAsSeries(close, true)) {
      Print("Falha ao definir o buffer como série temporal! Erro ", GetLastError());
      return(sinal);
   }
   
   //--- Verifica os dados do indicador para determinar os sinais de negociação
   if (close[2] <= bollingerBuffer2[1] && close[1] > bollingerBuffer2[1]) {
      sinal = 1;
   } else if (close[2] >= bollingerBuffer1[1] && close[1] < bollingerBuffer1[1]) {
      sinal = -1;
   } else {
      sinal = 0;
   }
   
   //--- Retorna o sinal de negociação
   return(sinal);
   
}

int CBollingerBands::sinalConfirmacao(int sinalNegociacao) {
   
   //--- O sinal é passado direto, uma vez que todas as condições de entrada na 
   //--- negociação foram previamente atendidas.
   int sinal = sinalNegociacao;
   
   //--- Retorna o sinal de confirmação
   return(sinal);
   
}

int CBollingerBands::sinalSaidaNegociacao(int chamadaSaida) {
   return(-1);
}

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Classe CEnvelopes - Sinais de negociação baseado na ruptura das  |
//| bordas Envelopes.                                                 |
//+------------------------------------------------------------------+
class CEnvelopes : public CStrategy {

   private:
      int envelopeHandle;
      
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

int CEnvelopes::init(void) {

   //--- Inicializa o indicador ADX
   this.envelopeHandle = iEnvelopes(_Symbol, _Period, 28, 0, MODE_SMA, PRICE_CLOSE, 0.1);
   
   //--- Verifica se os indicadores foram criados com sucesso
   if (this.envelopeHandle < 0) {
      Alert("Erro ao criar o indicador! Erro ", GetLastError());
      return(INIT_FAILED);
   }
   
   //--- Retorna o sinal de sucesso
   return(INIT_SUCCEEDED);
   
}

void CEnvelopes::release(void) {
   //--- Libera os indicadores
   IndicatorRelease(this.envelopeHandle);
}

int CEnvelopes::sinalNegociacao(void) {

   //--- Zero significa que não é pra abrir nenhum posição
   int sinal = 0;
   
   //-- Armaze os valores do indicador Envelopes e do close das últimas barras
   double envelopeBuffer1[], envelopeBuffer2[], close[];
   
   //--- Copia os valores dos indicadores para seus respectivos buffers
   if (CopyBuffer(this.envelopeHandle, 0, 0, 2, envelopeBuffer1) < 2
      || CopyBuffer(this.envelopeHandle, 1, 0, 2, envelopeBuffer2) < 2
      || CopyClose(_Symbol, _Period, 0, 3, close) < 3) {
      Print("Falha ao copiar os dados dos indicadores para os buffers! Erro ", GetLastError());
      return(sinal);
   }
   
   //--- Define os buffers como série temporal
   if (!ArraySetAsSeries(envelopeBuffer1, true) || !ArraySetAsSeries(envelopeBuffer2, true)
      || !ArraySetAsSeries(close, true)) {
      Print("Falha ao definir o buffer como série temporal! Erro ", GetLastError());
      return(sinal);
   }
   
   //--- Verifica os dados do indicador para determinar os sinais de negociação
   if (close[2] <= envelopeBuffer2[1] && close[1] > envelopeBuffer2[1]) {
      sinal = 1;
   } else if (close[2] >= envelopeBuffer1[1] && close[1] < envelopeBuffer1[1]) {
      sinal = -1;
   } else {
      sinal = 0;
   }
   
   //--- Retorna o sinal de negociação
   return(sinal);
   
}

int CEnvelopes::sinalConfirmacao(int sinalNegociacao) {
   
   //--- O sinal é passado direto, uma vez que todas as condições de entrada na 
   //--- negociação foram previamente atendidas.
   int sinal = sinalNegociacao;
   
   //--- Retorna o sinal de confirmação
   return(sinal);
   
}

int CEnvelopes::sinalSaidaNegociacao(int chamadaSaida) {
   return(-1);
}

//+------------------------------------------------------------------+

/* Desde ponto em diante ficam as declarações das classes das estratégias
   declaradas neste arquivo MQH
*/

//--- Declaração de classes
CAdxMA cAdxMA;
CBollingerBands cBollingerBands;
CEnvelopes cEnvelopes;

//+------------------------------------------------------------------+