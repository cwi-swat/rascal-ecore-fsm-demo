module lang::myfsm::MetaModel

import lang::ecore::Refs;

// All "meta-adts" need to have uid, might have src, and root models must have pkgURI.

data Machine(Id uid = noId(), loc src = noLoc(), loc pkgURI = |http://www.example.org/myfsm|)
  = Machine(str name, list[State] states, Ref[State] initial = null());
  
data State(Id uid = noId(), loc src = noLoc())
  = State(str name, list[Trans] transitions);
  
data Trans(Id uid = noId(), loc src = noLoc())
  = Trans(str event, Ref[State] target);
