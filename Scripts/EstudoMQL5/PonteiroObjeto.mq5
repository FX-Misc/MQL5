//+------------------------------------------------------------------+
//|                                               PonteiroObjeto.mq5 |
//|                              Copyright 2019, Hércules S. S. José |
//|                        https://www.linkedin.com/in/herculeshssj/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Hércules S. S. José"
#property link      "https://www.linkedin.com/in/herculeshssj/"
#property version   "1.00"

class Foo 
  { 
public: 
   string            m_name; 
   int               m_id; 
   static int        s_counter; 
   //--- construtores e desconstrutores 
                     Foo(void){Setup("noname");}; 
                     Foo(string name){Setup(name);}; 
                    ~Foo(void){}; 
   //--- inicializar objetos do tipo Foo 
   void              Setup(string name) 
     { 
      m_name=name; 
      s_counter++; 
      m_id=s_counter; 
     } 
  }; 
int Foo::s_counter=0; 


//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   //--- Declarar um objeto como variável com sua criação automática 
   Foo foo1; 
//--- Variante para passar um objeto por referência 
   PrintObject(foo1); 
  
//--- Declarar um ponteiro para um objeto e criá-lo usando o operador 'novo' 
   Foo *foo2=new Foo("foo2"); 
//--- Variante para passar um ponteiro para um objeto por referência 
   PrintObject(foo2); // ponteiro para um objeto é convertido automaticamente pelo compilador 
  
//--- Declarar um array de objetos do tipo Foo 
   Foo foo_objects[5]; 
//--- Variante de passagem de um array de objetos 
   PrintObjectsArray(foo_objects); // Função separada para passar um array de objetos 
  
//--- Declarar um array de ponteiros para objetos do tipo Foo 
   Foo *foo_pointers[5]; 
   for(int i=0;i<5;i++) 
     { 
      foo_pointers[i]=new Foo("foo_pointer"); 
     } 
//--- Variante para passar um array de ponteiros 
   PrintPointersArray(foo_pointers); // Função separada para passar um array de ponteiros 
  
//--- É obrigatório excluir objetos criados como ponteiros antes da terminação 
   delete(foo2); 
//--- deletar array de ponteiros 
   int size=ArraySize(foo_pointers); 
   for(int i=0;i<5;i++) 
      delete(foo_pointers[i]); 
//---    

  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+ 
//| Os objetos são sempre passados por referência                    | 
//+------------------------------------------------------------------+ 
void PrintObject(Foo &object) 
  { 
   Print(__FUNCTION__,": ",object.m_id," Object name=",object.m_name); 
  } 
//+------------------------------------------------------------------+ 
//| Passando um array de objetos                                     | 
//+------------------------------------------------------------------+ 
void PrintObjectsArray(Foo &objects[]) 
  { 
   int size=ArraySize(objects); 
   for(int i=0;i<size;i++) 
     { 
      PrintObject(objects[i]); 
     } 
  } 
//+------------------------------------------------------------------+ 
//| Passando um array de ponteiros para objeto                       | 
//+------------------------------------------------------------------+ 
void PrintPointersArray(Foo* &objects[]) 
  { 
   int size=ArraySize(objects); 
   for(int i=0;i<size;i++) 
     { 
      PrintObject(objects[i]); 
     } 
  } 
//+------------------------------------------------------------------+