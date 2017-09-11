module lang::myfsm::Trafos

import lang::myfsm::MetaModel;
import lang::ecore::Refs;
import lang::ecore::Diff;


Patch runAddState(&T<:node(type[&T<:node]) getIt) {
  Machine m = getIt(#Machine);
  return diff(#Machine, m, addState(m));
} 


Machine addState(Machine m) {
  r = newRealm();
  m.states += [r.new(#State, state("NewState", []))];
  return m;
}
