module lang::myfsm::Syntax

extend lang::std::Layout;
extend lang::std::Id;

start syntax Machine
  = @ref{initial:State:/states[name=$initial]} 
  "machine" Id name "init" Id initial State* states "end"
  ;
  
syntax State
  = @id{"name"} "state" Id name Trans* transitions "end"
  ;
  
  
syntax Trans
  = @ref{target:State:/states[name=$target]} 
  "on" Id event "=\>" Id target 
  ;
  
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
