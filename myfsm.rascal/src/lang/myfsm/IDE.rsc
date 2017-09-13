module lang::myfsm::IDE

import lang::myfsm::Syntax;
import lang::ecore::Tree2Model;
import lang::ecore::IO;
import lang::myfsm::MetaModel;

import util::IDE;
import ParseTree;
import Message;
import IO;



void main() {
  registerLanguage("MyFSM", "mf", start[Machine](str src, loc org) {
    return parse(#start[Machine], src, org);
  });
  
  registerContributions("MyFSM", {
    builder(set[Message](start[Machine] m) {
      modelURI = m@\loc[extension="myfsm"];
      model = tree2model(#lang::myfsm::MetaModel::Machine, m, uri=modelURI);
      save(model, modelURI, |http://www.example.org/myfsm|);
      iprintln(model);
      return {};
    })
  });
}