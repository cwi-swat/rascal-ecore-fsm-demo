module lang::myfsm::IDE

import lang::myfsm::Syntax;
import lang::ecore::Tree2Model;
import lang::ecore::IO;
import lang::ecore::Diff;
import lang::myfsm::MetaModel;

import util::IDE;
import ParseTree;
import Message;
import IO;



void main() {
  map[loc, void(Patch(lang::myfsm::MetaModel::Machine))] editors = ();
  registerLanguage("MyFSM", "mf", start[Machine](str src, loc org) {
    start[Machine] m = parse(#start[Machine], src, org);
    return m;
  });
  
  registerContributions("MyFSM", {
    builder(set[Message](start[Machine] m) {
      modelURI = m@\loc[extension="myfsm"];
      model = tree2model(#lang::myfsm::MetaModel::Machine, m, uri=modelURI);
      
      if (!(modelURI in editors)) {
        editors[modelURI] = editor(#lang::myfsm::MetaModel::Machine, modelURI);
      }
      ed = editors[modelURI];
      try {
        new = tree2model(#lang::myfsm::MetaModel::Machine, m, uri=modelURI);
        ed(Patch(lang::myfsm::MetaModel::Machine old) {
          p = diff(#lang::myfsm::MetaModel::Machine, old, new);
          return p;
        });
	  }
	  catch value exc: {
	      return {error("<exc>", m@\loc)};
	  }      
      return {};
    })
  });
}