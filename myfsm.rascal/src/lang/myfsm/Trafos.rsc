module lang::myfsm::Trafos

import lang::myfsm::MetaModel;
import lang::ecore::Refs;
import lang::ecore::Diff;

import List;
import IO;

Patch runAddState(Loader[&T<:node] load) {
  Machine m = load(#Machine);
  Patch patch = diff(#Machine, m, addState(m));
  iprintln(patch);
  return patch;
} 


Machine addState(Machine m) {
  r = newRealm();
  m.states += [r.new(#State, State("NewState_<size(m.states)>", []))];
  return m;
}
