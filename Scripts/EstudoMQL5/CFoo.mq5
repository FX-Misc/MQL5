//+------------------------------------------------------------------+
//|                                                         CFoo.mq5 |
//|                              Copyright 2019, Hércules S. S. José |
//|                        https://www.linkedin.com/in/herculeshssj/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Hércules S. S. José"
#property link      "https://www.linkedin.com/in/herculeshssj/"
#property version   "1.00"

//+------------------------------------------------------------------+ 
//| Uma classe com um construtor default                             | 
//+------------------------------------------------------------------+ 
class CFoo 
  { 
   datetime          m_call_time;     // Hora da última chamada ao objeto 
public: 
   //--- Um construtor com um parâmetro que tem um valor default não é um construtor default 
   CFoo(const datetime t = 0)
   {
      m_call_time = t;
   }; 
   //--- Um construtor copiador 
   CFoo(const CFoo &foo)
   {
      m_call_time = foo.m_call_time;
   }; 
  
   string ToString()
   {
      return(TimeToString(m_call_time, TIME_DATE|TIME_SECONDS ));
   }; 
   
  }; 


//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   // CFoo foo; // Esta variação não pode ser utilizada - um construtor default não foi definido 
//--- Possíveis opções para criar o objeto CFoo 
   CFoo fooText;
   CFoo foo1(TimeCurrent());     // Uma explicita chamada de um construtor paramétrico 
   CFoo foo2();                  // Uma explícita chamada de um construtor paramétrico com parâmetro default 
   CFoo foo3=D'2009.09.09';      // Uma implícita chamada de um construtor paramétrico 
   CFoo foo40(foo1);             // Uma explicita chamada de um construtor copiador 
   CFoo foo41=foo1;              // Uma implícita chamada de um construtor copiador 
   CFoo foo5;                    // Uma explícita chamada de um construtor default (se não existir construtor default, 
                                 // então um construtor paramétrico com um valor default é chamado) 
//--- Possíveis opções para criar o objeto CFoo 
   CFoo *pfoo6=new CFoo();       // Criação dinâmica de um objeto e recepção de um ponteiro para ele 
   CFoo *pfoo7=new CFoo(TimeCurrent());// Outra opções de criação dinâmica de objeto 
   CFoo *pfoo8=GetPointer(foo1); // Agora pfoo8 aponta para o objeto foo1 
   CFoo *pfoo9=pfoo7;            // pfoo9 e pfoo7 apontam para o mesmo objeto 
   // CFoo foo_array[3];         // Esta opção não pode ser usado - um construtor default não foi especificado 
//--- Mostra os valores de m_call_time 
   Print("foo1.m_call_time=",foo1.ToString()); 
   Print("foo2.m_call_time=",foo2.ToString()); 
   Print("foo3.m_call_time=",foo3.ToString()); 
   Print("foo40.m_call_time=",foo40.ToString()); 
   Print("foo41.m_call_time=",foo41.ToString()); 
   Print("foo5.m_call_time=",foo5.ToString()); 
   Print("pfoo6.m_call_time=",pfoo6.ToString()); 
   Print("pfoo7.m_call_time=",pfoo7.ToString()); 
   Print("pfoo8.m_call_time=",pfoo8.ToString()); 
   Print("pfoo9.m_call_time=",pfoo9.ToString()); 
   Print("fooTest.m_call_time=", fooText.ToString());
//--- Exclui dinamicamente arrays criados 
   delete pfoo6; 
   delete pfoo7;
   //delete pfoo8;  // Você não precisa excluir pfoo8 explicitamente, já que ele aponta para o objeto foo1 criado automaticamente 
   //delete pfoo9;  // Você não precisa excluir pfoo9 explicitamente, já que ele aponta para o mesmo objeto que pfoo7 
  }
//+------------------------------------------------------------------+
