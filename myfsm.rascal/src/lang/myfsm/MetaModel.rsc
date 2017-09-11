module lang::myfsm::MetaModel

import lang::ecore::Refs;

data Machine(Id uid = noId(), loc src = noLoc())
  = Machine(str name, list[State] states);
  
data State(Id uid = noId(), loc src = noLoc())
  = State(str name, list[Trans] transitions);
  
data Trans(Id uid = noId(), loc src = noLoc())
  = Trans(str event, Ref[State] target);
