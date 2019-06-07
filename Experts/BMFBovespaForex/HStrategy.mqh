//+------------------------------------------------------------------+
//|                                                       HStrategyh |
//|                            Copyright ® 2019, Hércules S. S. José |
//|                        https://www.linkedin.com/in/herculeshssj/ |
//+------------------------------------------------------------------+
#property copyright "Copyright ® 2019, Hércules S. S. José"
#property link      "https://www.linkedin.com/in/herculeshssj/"
#property description "Conjunto de classes contento várias estratégias para negociação."

//--- Enumerações
enum TIPO_ESTRATEGIA {
   CRUZAMENTO_MEDIA_MOVEL = 0, // Cruzamento MA
   TENDENCIA_MA_LONGA = 1, // Tendência MA longa
   TABAJARA = 2 // Indicador Tabajara
};

//+------------------------------------------------------------------+
//| Classe CStrategy - classe mãe para todas as estratégias de       |
//| de negociação.                                                   |
//+------------------------------------------------------------------+
class CStrategy {
      
   public:
      //--- Atributos
      double valorMACurta;
      double valorMALonga;
      int periodoMACurta;
      int periodoMALonga;
      ENUM_MA_METHOD metodoMACurta;
      ENUM_MA_METHOD metodoMALonga;

      //--- Métodos
      void CStrategy() {};            // Construtor
      void ~CStrategy() {};           // Construtor
      int cruzamentoMediaMovel(void);
      int tendenciaMALonga(void);
      int indicadorTabajara(void);
      
};

int CStrategy::cruzamentoMediaMovel(void) {
   
   //--- Zero significa que não é pra abrir nenhum posição
   int sinal = 0;
   
   double maCurtaBuffer[], maLongaBuffer[]; // Armazena os valores das médias móveis
   
   //--- Instanciação dos indicadores
   int maCurtaHandle = iMA(_Symbol, _Period, periodoMACurta, 0, metodoMACurta, PRICE_CLOSE);
   int maLongaHandle = iMA(_Symbol, _Period, periodoMALonga, 0, metodoMALonga, PRICE_CLOSE);
   
   //--- Verifica se os indicadores foram criados com sucesso
   if (maCurtaHandle < 0 || maLongaHandle < 0) {
      Alert("Erro ao criar os indicadores! Erro ", GetLastError());
      return(sinal);
   }
   
   //--- Copia o valor dos indicadores para seus respectivos buffers
   if (CopyBuffer(maCurtaHandle, 0, 0, 3, maCurtaBuffer) < 3
         || CopyBuffer(maLongaHandle, 0, 0, 3, maLongaBuffer) < 3) {
      Print("Falha ao copiar dados do indicador para o buffer! Erro ", GetLastError());
      return(sinal);
   }
   
   //--- Define os buffers como série temporal
   if (!ArraySetAsSeries(maCurtaBuffer, true) || !ArraySetAsSeries(maLongaBuffer, true)) {
      Print("Falha ao definir os buffers como série temporal! Erro ", GetLastError());
      return(sinal);
   }
   
   //--- Salva os valores da MA curta e longa da barra atual
   valorMACurta = maCurtaBuffer[0];
   valorMALonga = maLongaBuffer[0];
   
   //--- Verifica a MA das barras para determinar a tendência
   if (maCurtaBuffer[2] < maLongaBuffer[1] && maCurtaBuffer[1] > maLongaBuffer[1]) {
      // Tendência em alta
      sinal = 1;
   } else if (maCurtaBuffer[2] > maLongaBuffer[1] && maCurtaBuffer[1] < maLongaBuffer[1]) {
      // Tendência em baixa
      sinal = -1;
   } else {
      // Sem tendência
      sinal = 0;
   } 
   
   //--- Retorna o sinal de negociação
   return(sinal);
}

int CStrategy::tendenciaMALonga(void) {
   
   //--- Zero significa que não é pra abrir nenhum posição
   int sinal = 0;
   
   double maLongaBuffer[]; // Armazena os valores da média móvel longa
   
   //--- Instanciação do indicador
   int maLongaHandle = iMA(_Symbol, _Period, periodoMALonga, 0, metodoMALonga, PRICE_CLOSE);
   
   //--- Verifica se os indicadores foram criados com sucesso
   if (maLongaHandle < 0) {
      Alert("Erro ao criar o indicador! Erro ", GetLastError());
      return(sinal);
   }
   
   //--- Copia o valor do indicador para seu respectivo buffer
   if (CopyBuffer(maLongaHandle, 0, 0, 4, maLongaBuffer) < 4) {
      Print("Falha ao copiar dados do indicador para o buffer! Erro ", GetLastError());
      return(sinal);
   }
   
   //--- Define o buffer como série temporal
   if (!ArraySetAsSeries(maLongaBuffer, true)) {
      Print("Falha ao definir o buffer como série temporal! Erro ", GetLastError());
      return(sinal);
   }
   
   //--- Salva o valor da MA longa da barra atual
   valorMALonga = maLongaBuffer[0];
   
   //--- Verifica a MA das barras para determinar a tendência
   if (maLongaBuffer[3] < maLongaBuffer[2] && maLongaBuffer[2] < maLongaBuffer[1]
         && maLongaBuffer[3] < maLongaBuffer[1]) {
      //--- Tendência em alta
      sinal = 1;
   } else if (maLongaBuffer[3] > maLongaBuffer[2] && maLongaBuffer[2] > maLongaBuffer[1]
         && maLongaBuffer[3] > maLongaBuffer[1]) {
      //--- Tendência em baixa
      sinal = -1;
   } else {
      //--- Sem tendência
      sinal = 0;
   }
   
   //--- Retorna o sinal de negociação
   return(sinal);
}


//+-----------------------------------------------------------------------+
//| Estratégia de negociação baseado no indicador Tabajara                |
//| Mais detalhes sobre o indicador e o setup Tabajara, ver o link        |
//| https://dicionariodoinvestidor.com.br/content/o-que-e-setup-tabajara/ |
//+-----------------------------------------------------------------------+
int CStrategy::indicadorTabajara(void) {
   
   //--- Zero significa que não é pra abrir nenhum posição
   int sinal = 0;
   
   double mediaBuffer[]; // Armazena os valores da média móvel
   double candleBuffer[]; // Armazena os valores do candle
   
   //--- Instanciação do indicador
   int tabajaraHandle = iCustom(_Symbol, _Period, "Downloads\\tabajaraclassico1.01.ex5");
   
   //--- Verifica se os indicadores foram criados com sucesso
   if (tabajaraHandle < 0) {
      Alert("Erro ao criar o indicador! Erro ", GetLastError());
      return(sinal);
   }
   
   //--- Copia os valores do indicador para seus respectivos buffers
   if (CopyBuffer(tabajaraHandle, 1, 0, 1, mediaBuffer) < 1) {
      Print("Falha ao copiar dados do indicador para o buffer! Erro ", GetLastError());
      return(sinal);
   }
   if (CopyBuffer(tabajaraHandle, 6, 0, 1, candleBuffer) < 1) {
      Print("Falha ao copiar dados do indicador para o buffer! Erro ", GetLastError());
      return(sinal);
   }
   
   //--- Define o buffer como série temporal
   if (!ArraySetAsSeries(mediaBuffer, true)) {
      Print("Falha ao definir o buffer como série temporal! Erro ", GetLastError());
      return(sinal);
   }
   if (!ArraySetAsSeries(candleBuffer, true)) {
      Print("Falha ao definir o buffer como série temporal! Erro ", GetLastError());
      return(sinal);
   }
   
   //--- Obtém o sinal de negociação a partir de mediaBuffer (vermelho = venda, azul = compra)
   //--- O sinal é verificado com a cor do candle, para evitar a abertura de posição em momentos
   //--- desfavoráveis (candle preto ou cinza).
   
   //--- Sinal de venda
   if (mediaBuffer[0] == 0) {
      //--- Confirma o sinal usando o valor do candle
      if (candleBuffer[0] == 0) {
         sinal = -1;
      }
      
   }
   
   //--- Sinal de compra
   if (mediaBuffer[0] == 1) {
      //--- Confirma o sinal usando o valor do candle
      if (candleBuffer[0] == 1) {
         sinal = 1;
      }
      
   }
   
   //--- Retorna o sinal de negociação
   return(sinal);
}