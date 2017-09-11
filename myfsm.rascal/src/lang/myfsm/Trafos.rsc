module lang::myfsm::Trafos

import lang::myfsm::MetaModel;
import lang::ecore::Refs;
import lang::ecore::Diff;

import List;

Patch runAddState((&T<:node)(type[&T<:node]) getIt) {
  Machine m = getIt(#Machine);
  return diff(#Machine, m, addState(m));
} 


Machine addState(Machine m) {
  r = newRealm();
  m.states += [r.new(#State, State("NewState_<size(m.states)>", []))];
  return m;
}
