module lang::myfsm::Syntax

extend lang::std::Layout;
extend lang::std::Id;

start syntax Machine
  = @ref{initial:State:/states[name=$initial]} 
  Machine: "machine" Id name "init" Id initial State* states "end"
  ;
  
syntax State
  = State: "state" Id name Trans* transitions "end"
  ;
    
syntax Trans
  = @ref{target:State:/states[name=$target]} 
  Trans: "on" Id event "=\>" Id target 
  ;


lexical Id
  = "\<" Id ":" Id "\>";
  
Machine example() = (Machine)
`machine Doors
'  init closed
'
'  state closed
'    on open =\> opened
'    on lock =\> locked
'  end
' 
'  state opened
'    on close =\> closed
'  end
'  
'  state locked
'    on unlock =\> closed
'  end
'end`;


