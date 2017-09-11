module lang::myfsm::Syntax

extend lang::std::Layout;
extend lang::std::Id;

start syntax Machine
  = "machine" Id name State* states "end"
  ;
  
syntax State
  = "state" Id name Trans* transitions "end"
  ;
  
syntax Trans
  = @ref{target:State:/states[id=_]} "on" Id event "=\>" Id target 
  ;