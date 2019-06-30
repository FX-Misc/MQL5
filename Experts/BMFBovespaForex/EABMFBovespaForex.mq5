//+------------------------------------------------------------------+
//|                                            EABMFBovespaForex.mq5 |
//|                            Copyright ® 2019, Hércules S. S. José |
//|                        https://www.linkedin.com/in/herculeshssj/ |
//+------------------------------------------------------------------+
#property copyright "Copyright ® 2019, Hércules S. S. José"
#property link      "https://www.linkedin.com/in/herculeshssj/"
#property version   "1.09"

//--- Inclusão de arquivos
#include "Estrategias\HBMFBovespaForex.mqh"
#include "Estrategias\HMediasMoveis.mqh"
#include "Estrategias\HOsciladores.mqh"
#include <Trade\Trade.mqh>

//--- Variáveis estáticas
static int sinalAConfirmar = 0;
static double tamanhoLote = 0.1;
static double passoLote = 0.1;
static ENUM_SYMBOL_CALC_MODE mercadoAOperar = SYMBOL_CALC_MODE_FOREX;
static int magicNumber = 19851024;
static int tickBarraTimer = 1; // Padrão, nova barra

//--- Parâmetros de entrada
input ESTRATEGIA_NEGOCIACAO estrategiaNegociacao = BMFBOVESPA_FOREX;

//--- Declaração de classes
CTrade cTrade; // Classe com métodos para negociação obtido das bibliotecas do MetaTrader

//--- Classes de estratégia
CBMFBovespaForex cBMFBovespaForex;
CCruzamentoMACurtaAgil cCruzamentoMACurtaAgil;
CCruzamentoMALongaCurta cCruzamentoMALongaCurta;
CSinalEstocastico cSinalEstocastico;
CTendenciaNRTR cTendenciaNRTR;

//+------------------------------------------------------------------+
//| Inicialização do Expert Advisor                                  |
//+------------------------------------------------------------------+
int OnInit() {
   
   //--- Exibe informações sobre a conta de negociação
   cAccount.relatorioInformacoesConta();
   
   /*** Carrega os parâmetros do EA do arquivo ***/
   
   //--- Nome do arquivo
   string filename = IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN)) + "_" + _Symbol + ".bin";
   
   //--- Verifica se o arquivo existe
   if (FileIsExist(filename)) {
      //--- Abre o arquivo para leitura
      int fileHandle = FileOpen(filename, FILE_READ|FILE_BIN);
      if (fileHandle != INVALID_HANDLE) {
         //--- Lê o magic number do EA
         magicNumber = FileReadInteger(fileHandle);
         
         //--- Fecha o arquivo
         FileClose(fileHandle);
      }      
      
   } else {
   
      //--- Gera o magic number do EA
      MathSrand(GetTickCount());
      magicNumber = MathRand() * 255;
      
      //--- Abre o arquivo para escrita
      int fileHandle = FileOpen(filename, FILE_WRITE|FILE_BIN);
      if (fileHandle != INVALID_HANDLE) {
         // Grava o magic number do EA no arquivo
         FileWriteInteger(fileHandle, magicNumber);
         
         //--- Fecha o arquivo
         FileClose(fileHandle);
      }
   }
   
   //--- Cria um temporizador de 1 minuto
   EventSetTimer(60);
   
   //--- Inicializa a classe para stop móvel
   trailingStop.Init(_Symbol, _Period, magicNumber, true, true, false);
   
   //--- Carrega os parâmetros do indicador NRTR
   if (!trailingStop.setupParameters(40, 2)) {
      Alert("Erro na inicialização da classe de stop móvel! Saindo...");
      return(INIT_FAILED);
   }
   
   //--- Determina o tamanho do lote
   if (SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP) > passoLote) {
      passoLote = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
      tamanhoLote = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   }
   
   //--- Define o mercado que o EA está operando
   mercadoAOperar = (ENUM_SYMBOL_CALC_MODE)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_CALC_MODE);
   
   //--- Inicia o stop móvel para as posições abertas
   trailingStop.on();
   
   //--- Inicializa os indicadores usados pela estratégia
   int inicializarEA = INIT_FAILED;
   
   switch (estrategiaNegociacao) {
      case BMFBOVESPA_FOREX : 
         tickBarraTimer = cBMFBovespaForex.onTickBarTimer();
         inicializarEA = cBMFBovespaForex.init();
         break;
      case CRUZAMENTO_MA_CURTA_AGIL : 
         tickBarraTimer = cCruzamentoMACurtaAgil.onTickBarTimer();
         inicializarEA = cCruzamentoMACurtaAgil.init();
         break;
      case CRUZAMENTO_MA_LONGA_CURTA :
         tickBarraTimer = cCruzamentoMALongaCurta.onTickBarTimer();
         inicializarEA = cCruzamentoMALongaCurta.init();
         break;
      case SINAL_ESTOCASTICO : 
         tickBarraTimer = cSinalEstocastico.onTickBarTimer();
         inicializarEA = cSinalEstocastico.init();
         break;
      case TENDENCIA_NRTR :
         tickBarraTimer = cTendenciaNRTR.onTickBarTimer();
         inicializarEA = cTendenciaNRTR.init();
         break;
   }
   
   //--- Retorna o sinal de inicialização do EA   
   return(inicializarEA);
}

//+------------------------------------------------------------------+
//| Encerramento do Expert Advisor                                   |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {

   //--- Libera os indicadores usado pela estratégia
   switch (estrategiaNegociacao) {
      case BMFBOVESPA_FOREX :
         cBMFBovespaForex.release();
         break;
      case CRUZAMENTO_MA_CURTA_AGIL : 
         cCruzamentoMACurtaAgil.release();
         break;
      case CRUZAMENTO_MA_LONGA_CURTA :
         cCruzamentoMALongaCurta.release();
         break;
      case SINAL_ESTOCASTICO :
         cSinalEstocastico.release();
      case TENDENCIA_NRTR : 
         cTendenciaNRTR.release();
   }

   //--- Encerra o stop móvel
   trailingStop.Deinit();
   
   //--- Destrói o temporizador
   EventKillTimer();
}

//+------------------------------------------------------------------+
//| Método que recebe os ticks vindo do gráfico                      |
//+------------------------------------------------------------------+
void OnTick() {
   
   //--- Verifica se a estratégia aciona os sinais de negociação após uma
   //--- nova barra no gráfico
   if (tickBarraTimer == 1 && temNovaBarra()) {
      
      //--- Verifica se possui sinal de negociação a confirmar
      sinalAConfirmar = sinalNegociacao();
      if (sinalAConfirmar != 0) {
         confirmarSinal();         
      }
      
   //--- Verifica se a estratégia aciona os sinais de negociação após um novo tick
   } else if (tickBarraTimer == 0) {
   
      //--- Verifica se possui sinal de negociação a confirmar
      sinalAConfirmar = sinalNegociacao();
      if (sinalAConfirmar != 0) {
         confirmarSinal();         
      }
      
   }
   
   //--- Checa se as posições precisam ser encerradas
   if (temNovaBarra()) {
      sinalSaidaNegociacao(0);
   } else {
      sinalSaidaNegociacao(1);
   }
      
      
}

//+------------------------------------------------------------------+
//| Conjuntos de rotinas padronizadas a serem executadas a cada      |
//| minuto (60 segundos).                                            |
//+------------------------------------------------------------------+
void OnTimer() {

   //--- Atualiza os dados do stop móvel
   trailingStop.refresh();
   
   //--- Realiza o stop móvel das posições abertas
   for (int i = PositionsTotal() - 1; i >= 0; i--) {
      if (PositionSelectByTicket(PositionGetTicket(i)) && PositionGetString(POSITION_SYMBOL) == _Symbol) {
         trailingStop.doStopLoss(PositionGetTicket(i));
      }         
   }
   
   //--- Checa se as posições precisam ser encerradas
   sinalSaidaNegociacao(9);
   
   //--- Verifica se a estratégia aciona os sinais de negociação após transcorrer
   //--- o tempo no timer
   if (tickBarraTimer == 9) {
   
      //--- Verifica se possui sinal de negociação a confirmar
      sinalAConfirmar = sinalNegociacao();
      if (sinalAConfirmar != 0) {
         confirmarSinal();         
      }
            
   }
   
}

//+------------------------------------------------------------------+
//|  Função responsável por informar se o momento é de abrir uma     |
//|  posição de compra ou venda.                                     |
//|                                                                  |
//|  -1 - Abre uma posição de venda                                  |
//|  +1 - Abre uma posição de compra                                 |
//|   0 - Nenhum posição é aberta                                    |
//+------------------------------------------------------------------+
int sinalNegociacao() {

   //--- Obtém a hora atual
   MqlDateTime horaAtual;
   TimeCurrent(horaAtual);
   
   //--- Verifica se o mercado está aberto para negociações
   if (mercadoAberto(horaAtual)) {
   
      switch (estrategiaNegociacao) {
         case BMFBOVESPA_FOREX :
            return(cBMFBovespaForex.sinalNegociacao()); break;
         case CRUZAMENTO_MA_CURTA_AGIL : 
            return(cCruzamentoMACurtaAgil.sinalNegociacao()); break;
         case CRUZAMENTO_MA_LONGA_CURTA :
            return(cCruzamentoMALongaCurta.sinalNegociacao()); break;
         case SINAL_ESTOCASTICO :
            return(cSinalEstocastico.sinalNegociacao()); break;
         case TENDENCIA_NRTR :
            return(cTendenciaNRTR.sinalNegociacao()); break;
      }
   
   }
   
   return(0);
}

//+------------------------------------------------------------------+
//|  Função responsável por verificar se é o momento de encerrar a   |
//|  posição de compra ou venda aberta. Caso a estratégia retorna o  |
//|  valor 0 significa que as posições abertas para o símbolo atual  |
//|  devem ser encerradas.                                           |
//+------------------------------------------------------------------+
void sinalSaidaNegociacao(int chamadaSaida) {

   //--- O padrão é manter as posições abertas
   int sinal = -1;

   switch (estrategiaNegociacao) {
      case BMFBOVESPA_FOREX :
         sinal = cBMFBovespaForex.sinalSaidaNegociacao(chamadaSaida); break;
      case CRUZAMENTO_MA_CURTA_AGIL : 
         sinal = cCruzamentoMACurtaAgil.sinalSaidaNegociacao(chamadaSaida); break;
      case CRUZAMENTO_MA_LONGA_CURTA :
         sinal = cCruzamentoMALongaCurta.sinalSaidaNegociacao(chamadaSaida); break;
      case SINAL_ESTOCASTICO :
         sinal = cSinalEstocastico.sinalSaidaNegociacao(chamadaSaida); break;
      case TENDENCIA_NRTR :
         sinal = cTendenciaNRTR.sinalSaidaNegociacao(chamadaSaida); break;
   }
   
   //--- Verifica o sinal de saída da negociação aberta
   if (sinal == 0) {
      //--- Encerra as posições para o símbolo atual
      for (int i = PositionsTotal() - 1; i >= 0; i--) {
         if (PositionSelectByTicket(PositionGetTicket(i)) && PositionGetString(POSITION_SYMBOL) == _Symbol) {
            string mensagem = "Ticket #" 
               + IntegerToString(PositionGetTicket(i)) 
               + " do símbolo " + _Symbol + " fechado com o lucro/prejuízo de " 
               + DoubleToString(PositionGetDouble(POSITION_PROFIT));
            cTrade.PositionClose(PositionGetTicket(i));
            cUtil.enviarMensagem(CONSOLE, mensagem);
         }
      }
   }
}

//+------------------------------------------------------------------+
//|  Função responsável por confirmar se o momento é de abrir uma    |
//|  posição de compra ou venda. Esta função é chamada sempre que se |
//|  obter a confirmação do sinal a partir de outro indicador ou     |
//|  outra forma de cálculo.                                         |
//|                                                                  |
//|  -1 - Confirma a abertura da posição de venda                    |
//|  +1 - Confirma a abertura da posição de compra                   |
//|   0 - Informa que nenhuma posição deve ser aberta                |
//+------------------------------------------------------------------+
int sinalConfirmacao() {
   
   switch (estrategiaNegociacao) {
      case BMFBOVESPA_FOREX :
         return(cBMFBovespaForex.sinalConfirmacao(sinalAConfirmar)); break;
      case CRUZAMENTO_MA_CURTA_AGIL : 
         return(cCruzamentoMACurtaAgil.sinalConfirmacao(sinalAConfirmar)); break;
      case CRUZAMENTO_MA_LONGA_CURTA :
         return(cCruzamentoMALongaCurta.sinalConfirmacao(sinalAConfirmar)); break;
      case SINAL_ESTOCASTICO : 
         return(cSinalEstocastico.sinalConfirmacao(sinalAConfirmar)); break;
      case TENDENCIA_NRTR :
         return(cTendenciaNRTR.sinalConfirmacao(sinalAConfirmar)); break;
   }
   
   return(0);
}

//+------------------------------------------------------------------+
//|  Função responsável por confirmar o sinal de negociação indicado |
//|  na abertura da nova barra e abrir uma nova posição de compra/   |
//|  venda de acordo com a tendência do mercado.                     |
//+------------------------------------------------------------------+
void confirmarSinal() {

   //--- Obtém o sinal de confirmação recebido
   int sinalConfirmado = sinalConfirmacao();
   
   //--- Caso o sinal confirmado seja 9 ou -9, sai do método e quem deverá abrir a posição
   //--- será o timer
   if (sinalConfirmado == 9 || sinalConfirmado == -9) {
      sinalAConfirmar = sinalConfirmado;
      return;
   }

   if (sinalAConfirmar > 0 && sinalConfirmado == 1) {
      
      //--- Verifica se existe uma posição de compra já aberta
      if (existePosicoesAbertas(POSITION_TYPE_BUY)) {
         //--- Substituir com algum código útil
      } else {
                  
         //--- Confere se a posição contrária foi realmente fechada
         if (!existePosicoesAbertas(POSITION_TYPE_SELL)) {
            //--- Abre a nova posição de compra
            realizarNegociacao(ORDER_TYPE_BUY);
         }
         
      }
      
   } else if (sinalAConfirmar < 0 && sinalConfirmado == -1) {
         
      //--- Verifica se existe uma posição de venda já aberta
      if (existePosicoesAbertas(POSITION_TYPE_SELL)) {
         //--- Substituir com algum código útil
      } else {
         
         //--- Confere se a posição contrária foi realmente fechada
         if (!existePosicoesAbertas(POSITION_TYPE_BUY)) {
         
            //--- Abre a nova posição de venda
            realizarNegociacao(ORDER_TYPE_SELL);
         }
      }
      
   } else {
      //--- Substituir com algum código útil
   }
   
}
   
//+------------------------------------------------------------------+
//|  Função responsável por realizar a negociação propriamente dita, |
//|  obtendo as informações do último preço recebido para calcular o |
//|  spread, stop loss e take profit da ordem a ser enviada.         |
//+------------------------------------------------------------------+   
void realizarNegociacao(ENUM_ORDER_TYPE tipoOrdem) {

   //--- Obtém o valor do spread
   int spread = (int)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
   
   //--- Obtém o tamanho do tick
   double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   
   //--- Obtém as informações do último preço da cotação
   MqlTick ultimoPreco;
   if (!SymbolInfoTick(_Symbol, ultimoPreco)) {
      Print("Erro ao obter a última cotação! - Erro ", GetLastError());
      return;
   }
   
   if (tipoOrdem == ORDER_TYPE_BUY) {
   
      // Verifica se existe margem disponível para abertura na nova posição de compra
      if (!cOrder.possuiMargemParaAbrirNovaPosicao(tamanhoLote, _Symbol, POSITION_TYPE_BUY)) {
         //--- Emite um alerta informando a falta de margem disponível
         cUtil.enviarMensagem(TERMINAL, "Sem margem disponível para abertura de novas posições!");
         return;
      }
      
      //--- Ajusta o preço nos casos do tick vier com um valor inválido
      double preco = ultimoPreco.ask;
      
      if (mercadoAOperar == SYMBOL_CALC_MODE_EXCH_STOCKS || mercadoAOperar == SYMBOL_CALC_MODE_EXCH_FUTURES) {
         // Diminui o resto da divisão do preço com o tick size para igualar ao
         // último múltiplo do valor de tick size
         if (fmod(preco, tickSize) != 0) {
            preco = preco - fmod(preco, tickSize);
         }
      }
   
      /*** Calcula o stop loss ***/
      
      //--- Atualiza os valores do indicador
      trailingStop.refresh();
      
      //--- Pega o valor do indicador
      double sl = trailingStop.buyStopLoss();
      
      //--- Normaliza os valores      
      sl = NormalizeDouble(sl, _Digits);
      
      if (mercadoAOperar == SYMBOL_CALC_MODE_EXCH_STOCKS || mercadoAOperar == SYMBOL_CALC_MODE_EXCH_FUTURES) {
         // Diminui o resto da divisão do preço com o tick size para igualar ao
         // último múltiplo do valor de tick size
         if (fmod(sl, tickSize) != 0) {
            sl = sl - fmod(sl, tickSize);
         }
      }
      
      //--- Verifica se o símbolo tem nívem mínimo de stop loss
      if (SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) != 0) {
      
         //--- Obtém o nível mínimo de stop do símbolo escolhido
         double minimoSL = SymbolInfoDouble(_Symbol, SYMBOL_BID) - _Point * SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
         
         //--- Normaliza o valor
         minimoSL = NormalizeDouble(minimoSL, _Digits);
         
         if (mercadoAOperar == SYMBOL_CALC_MODE_EXCH_STOCKS || mercadoAOperar == SYMBOL_CALC_MODE_EXCH_FUTURES) {
            // Diminui o resto da divisão do preço com o tick size para igualar ao
            // último múltiplo do valor de tick size
            if (fmod(minimoSL, tickSize) != 0) {
               minimoSL = minimoSL - fmod(minimoSL, tickSize);
            }
         }
      
         //--- O maior valor entre 'sl' e 'minimoSL' será atribuído ao stop loss
         sl = MathMin(sl, minimoSL);
      }
      
      //--- Envia a ordem de compra
      cOrder.enviaOrdem(ORDER_TYPE_BUY, TRADE_ACTION_DEAL, preco, tamanhoLote, sl, 0);
   
   } else {
   
      // Verifica se existe margem disponível para abertura na nova posição de venda
      if (!cOrder.possuiMargemParaAbrirNovaPosicao(tamanhoLote, _Symbol, POSITION_TYPE_SELL)) {
         //--- Emite um alerta informando a falta de margem disponível
         cUtil.enviarMensagem(TERMINAL, "Sem margem disponível para abertura de novas posições!");
         return;
      }
      
      //--- Ajusta o preço nos casos do tick vier com um valor inválido
      double preco = ultimoPreco.bid;
      
      if (mercadoAOperar == SYMBOL_CALC_MODE_EXCH_STOCKS || mercadoAOperar == SYMBOL_CALC_MODE_EXCH_FUTURES) {
         // Diminui o resto da divisão do preço com o tick size para igualar ao
         // último múltiplo do valor de tick size
         if (fmod(preco, tickSize) != 0) {
            preco = preco - fmod(preco, tickSize);
         }
      }
   
      /*** Calcula o stop loss ***/
      
      //--- Atualiza os valores do indicador
      trailingStop.refresh();
      
      //--- Pega o valor do indicador
      double sl = trailingStop.sellStopLoss();
      
      //--- Normaliza o valor
      sl = NormalizeDouble(sl, _Digits);
      
      if (mercadoAOperar == SYMBOL_CALC_MODE_EXCH_STOCKS || mercadoAOperar == SYMBOL_CALC_MODE_EXCH_FUTURES) {
         // Diminui o resto da divisão do preço com o tick size para igualar ao
         // último múltiplo do valor de tick size
         if (fmod(sl, tickSize) != 0) {
            sl = sl - fmod(sl, tickSize);
         }
      }
      
      //--- Verifica se o símbolo tem nívem mínimo de stop loss
      if (SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) != 0) {
      
         //--- Obtém o nível mínimo de stop do símbolo escolhido
         double minimoSL = SymbolInfoDouble(_Symbol, SYMBOL_ASK) + _Point * SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
         
         //--- Normaliza o valor
         minimoSL = NormalizeDouble(minimoSL, _Digits);
         
         if (mercadoAOperar == SYMBOL_CALC_MODE_EXCH_STOCKS || mercadoAOperar == SYMBOL_CALC_MODE_EXCH_FUTURES) {
            // Diminui o resto da divisão do preço com o tick size para igualar ao
            // último múltiplo do valor de tick size
            if (fmod(minimoSL, tickSize) != 0) {
               minimoSL = minimoSL - fmod(minimoSL, tickSize);
            }
         }
      
         //--- O maior valor entre 'sl' e 'minimoSL' será atribuído ao stop loss
         sl = MathMax(sl, minimoSL);
      }

      //--- Envia a ordem de venda
      cOrder.enviaOrdem(ORDER_TYPE_SELL, TRADE_ACTION_DEAL, preco, tamanhoLote, sl, 0);
    
   } 
}

//+------------------------------------------------------------------+ 
//|  Retorna true quando aparece uma nova barra no gráfico           |
//|  Função obtida no seguinte tópico de ajuda:                      |
//|  https://www.mql5.com/pt/docs/event_handlers/ontick              |
//+------------------------------------------------------------------+ 
bool temNovaBarra() {

   static datetime barTime = 0; // Armazenamos o tempo de abertura da barra atual
   datetime currentBarTime = iTime(_Symbol, _Period, 0); // Obtemos o tempo de abertura da barra zero
   
   //-- Se o tempo de abertura mudar, é porque apareceu uma nova barra
   if (barTime != currentBarTime) {
      barTime = currentBarTime;
      if (MQL5InfoInteger(MQL5_DEBUGGING)) {
         //--- Exibimos uma mensagem sobre o tempo de abertura da nova barra
         PrintFormat("%s: nova barra em %s %s aberta em %s", __FUNCTION__, _Symbol,
            StringSubstr(EnumToString(_Period), 7), TimeToString(TimeCurrent(), TIME_SECONDS));
      }
      
      return(true); // temos uma nova barra
   }

   return(false); // não há nenhuma barra nova
}

//+------------------------------------------------------------------+ 
//|  Retorna true caso esteja dentro do perído permitido pelo        |
//|  mercado que o usuário está operando (BM&FBovespa ou Forex).     |
//|                                                                  |
//|  Todas as ordens pendentes e posições abertas são encerradas     |
//|  quando estão fora dos horários dos pregões.                     |
//+------------------------------------------------------------------+  
bool mercadoAberto(MqlDateTime &hora) {

   switch(mercadoAOperar) {
      case SYMBOL_CALC_MODE_EXCH_STOCKS:
      case SYMBOL_CALC_MODE_EXCH_FUTURES:
         //--- Verifica se a hora está entre 10h e 17h
         if (hora.hour >= 10 && hora.hour < 17) {
            return(true);
         }      
         break;
      case SYMBOL_CALC_MODE_FOREX:
         if ( (hora.day_of_week == 1 && hora.hour == 0) || (hora.day_of_week == 5 && hora.hour == 23) ) {
            //--- Sai do switch para poder fechar as ordens e posições abertas
            break;
         } else {
            return(true);
         }
         
         break;
   }
   
   //--- Caso a hora não se encaixa em nenhuma das condições acima, todas as ordens
   //--- pendentes e posições abertas são fechadas
   
   //-- Exclui todas as ordens pendentes
   if (OrdersTotal() > 0) {
      for (int i = OrdersTotal() - 1; i >= 0; i--) {
         cTrade.OrderDelete(OrderGetTicket(i));
      }
   }
      
   //-- Fecha todas as posições abertas
   if (PositionsTotal() > 0) {
      for (int i = PositionsTotal() - 1; i >= 0; i--) {
         cTrade.PositionClose(PositionGetTicket(i));
      }
   }
   
   return(false);
}

//+------------------------------------------------------------------+ 
//|  Fecha todas as posições que estão atualmente abertas            |
//+------------------------------------------------------------------+  
void fecharTodasPosicoes() {
   
   for (int i = PositionsTotal() - 1; i >= 0; i--) {
      Print("Ticket #", PositionGetTicket(i), " do símbolo ", _Symbol, " fechado com o lucro/prejuízo aproximado de ", PositionGetDouble(POSITION_PROFIT));
      cTrade.PositionClose(PositionGetTicket(i));
   }
}

//+------------------------------------------------------------------+ 
//|  Fecha todas as posições que estão atualmente abertas            |
//+------------------------------------------------------------------+  
void fecharPosicoesAbertas(ENUM_POSITION_TYPE typeOrder) {
   
   /* Fecha a posição anteriormente abertas */
   for (int i = PositionsTotal() - 1; i >= 0; i--) {
      // Verifica se a posição aberta é uma posição inversa
      if (PositionSelectByTicket(PositionGetTicket(i)) && PositionGetString(POSITION_SYMBOL) == _Symbol
         && ((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)) == typeOrder) {
         Print("Ticket #", PositionGetTicket(i), " do símbolo ", _Symbol, " fechado com o lucro/prejuízo aproximado de ", PositionGetDouble(POSITION_PROFIT));
         cTrade.PositionClose(PositionGetTicket(i));
      }
   }
}  

//+------------------------------------------------------------------+ 
//|  Verifica se existe posição aberta para o símbolo atualmente     |
//|  selecionado. Retorna false caso não tenha nenhuma posição aberta|
//|  para o tipo de posição informado.                               |
//+------------------------------------------------------------------+
bool existePosicoesAbertas(ENUM_POSITION_TYPE tipoPosicao) {
   int contadorCompra = 0;
   int contadorVenda = 0;
   for (int i = PositionsTotal() - 1; i >= 0; i--) {
      if (PositionSelectByTicket(PositionGetTicket(i)) && PositionGetString(POSITION_SYMBOL) == _Symbol) {
         if ( ((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)) == POSITION_TYPE_BUY ) {
            contadorCompra++;
         } else {
            contadorVenda++;
         }
      }
   }
   
   if (tipoPosicao == POSITION_TYPE_BUY && contadorCompra > 0) {
      return(true);
   }
   if (tipoPosicao == POSITION_TYPE_SELL && contadorVenda > 0) {
      return(true);
   }
   
   return(false);
}

void mostrarMensagem(string mensagem) {
   if (MQL5InfoInteger(MQL5_DEBUGGING) || MQL5InfoInteger(MQL5_DEBUG) || MQL5InfoInteger(MQL5_TESTER) || MQL5InfoInteger(MQL5_TESTING)) {
      Print(mensagem);
   }
}
//+------------------------------------------------------------------+