//+------------------------------------------------------------------+
//|                                                NRTRIndicator.mq5 |
//|                            Copyright ® 2019, Hércules S. S. José |
//|                        https://www.linkedin.com/in/herculeshssj/ |
//+------------------------------------------------------------------+
#property copyright "Copyright ® 2019, Hércules S. S. José"
#property link      "https://www.linkedin.com/in/herculeshssj/"
#property version   "1.00"
#property description "Artigo: Indicador NRTR e módulos de negociação baseados nele para o assistente MQL5"
#property description "Link: https://www.mql5.com/pt/articles/3690"
#property indicator_chart_window
#property indicator_buffers   4
#property indicator_plots     4

//--- Indicator lines style
#property indicator_type1  DRAW_LINE
#property indicator_color1 Green
#property indicator_style1 STYLE_DASH

#property indicator_type2  DRAW_LINE
#property indicator_color2 Red
#property indicator_style2 STYLE_DASH

#property indicator_type3  DRAW_ARROW
#property indicator_color3 Green

#property indicator_type4  DRAW_ARROW
#property indicator_color4 Red


//-- Buffers and external parameters
input int      period = 12;  // período dinâmico
input double   percent = 0.2; // porcentagem de recuo

double bufferUp[], bufferDown[];
double signUp[], signDown[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
   IndicatorSetString(INDICATOR_SHORTNAME, "NRTR");
   
   SetIndexBuffer(0, bufferUp, INDICATOR_DATA);
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, 0.0);
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,clrGreen);
   PlotIndexSetInteger(0, PLOT_LINE_WIDTH, 2);
   ArraySetAsSeries(bufferUp, true);
   
   SetIndexBuffer(1, bufferDown, INDICATOR_DATA);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, 0.0);
   PlotIndexSetInteger(1,PLOT_LINE_COLOR,clrRed);
   PlotIndexSetInteger(1, PLOT_LINE_WIDTH, 2);
   ArraySetAsSeries(bufferDown, true);
   
   SetIndexBuffer(2, signUp, INDICATOR_DATA);
   PlotIndexSetDouble(2, PLOT_EMPTY_VALUE, 0.0);
   PlotIndexSetInteger(2, PLOT_ARROW, 236);
   PlotIndexSetInteger(2, PLOT_LINE_WIDTH, 1);
   ArraySetAsSeries(signUp, true);

   SetIndexBuffer(3, signDown, INDICATOR_DATA);
   PlotIndexSetDouble(3, PLOT_EMPTY_VALUE, 0.0);
   PlotIndexSetInteger(3, PLOT_ARROW, 238);
   PlotIndexSetInteger(3, PLOT_LINE_WIDTH, 1);
   ArraySetAsSeries(signDown, true);   
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   
   int start = 0; // Ponto de cálculo
   
   int trend = 0; // Valor da tendência ascendente 1, descendente -1
   static int previousTrend = 0; 
   
   double value = 0; // Valor do indicador
   static double previousValue = 0;
   
   int dynamicPeriod = 1; // Valor do período
   static int currentPeriod = 1;
   
   double maxMin = 0; // Variável técnica para os cálculos
   
   ArraySetAsSeries(close, true);
   
   if (rates_total < period) {
      return(0);
   }
   
   // Verificação do início - primeiro cálculo do indicador
   if (prev_calculated == 0) {
      start = rates_total - 1; // Número inicial para o cálculo de todas as barras
      previousTrend = 1;
      value = close[start] * (1 - 0.01 * percent);
   } else {
      start = rates_total - prev_calculated; // Número inicial para o cálculo das barras novas
   }
   
   trend = previousTrend;
   value = previousValue;
   dynamicPeriod = currentPeriod;   
   
   //-------------------------------------------------------------------+
   //                        Ciclo de cálculo principal   
   //-------------------------------------------------------------------+  
   
   for (int i = start; i >= 0; i--) {
      bufferUp[i] = 0.0;
      bufferDown[i] = 0.0;
      signUp[i] = 0.0;
      signDown[i] = 0.0;
      
      if (currentPeriod > period) {
         currentPeriod = period;
      }
      if (dynamicPeriod > period) {
         dynamicPeriod = period;
      }
      
      // If trend ascending
      if (trend > 0) {
         maxMin = close[ArrayMaximum(close, i, dynamicPeriod)];
         value = maxMin * (1 - percent * 0.01);
         
         if (close[i] < value) {
            maxMin = close[i];
            value = maxMin * (1 - percent * 0.01);
            trend = -1;
            dynamicPeriod = 1;
         }
      } else {
         // If trend descending
         maxMin = close[ArrayMinimum(close, i, dynamicPeriod)];
         value = maxMin * (1 - percent * 0.01);
         
         if (close[i] > value) {
            maxMin = close[i];
            value = maxMin * (1 - percent * 0.01);
            trend = 1;
            dynamicPeriod = 1;
         }
      }
      
      // Trend changes
      if (trend > 0) {
         bufferUp[i] = value;
      }
      if (trend < 0) {
         bufferDown[i] = value;
      }
      if (previousTrend < 0 && trend > 0) {
         signUp[i] = value;
         bufferUp[i] = 0.0;
      }
      if (previousTrend > 0 && trend < 0) {
         signDown[i] = value;
         bufferDown[i] = 0.0;
      }
      
      dynamicPeriod++;
      
      if (i) {
         previousTrend = trend;
         previousValue = value;
         if (dynamicPeriod == 2) {
            currentPeriod = 2;
         } else {
            currentPeriod++;
         }
      }
      
   }
 
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
