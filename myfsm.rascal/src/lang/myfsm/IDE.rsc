module lang::myfsm::IDE

import lang::myfsm::Syntax;
import lang::ecore::Tree2Model;
import lang::ecore::PatchTree;
import lang::ecore::PTDiff;
import lang::ecore::IO;
import lang::ecore::Diff;
import lang::myfsm::MetaModel;

import util::IDE;
import ParseTree;
import Message;
import IO;



void main() {
  map[loc, void(Patch(lang::myfsm::MetaModel::Machine))] modelEditors = ();
  map[loc, void(lang::myfsm::MetaModel::Machine)] observers = ();
  map[loc, void(lrel[loc, str])] termEditors = ();
  map[loc, lang::myfsm::MetaModel::Machine] models = ();
  map[loc, lang::myfsm::Syntax::Machine] terms = ();
  
  loc modelLoc(loc l) = l[extension="myfsm"];
  
  
  myModel = |project://TestIt/src/doors.myfsm|;
  myTerm = myModel[extension="mf"];
  termEditors[myTerm] = termEditor(myModel[extension="mf"]);
  
  bool token = false;
  
  // NB: all trees are non-top now...
  observers[myModel] = void(lang::myfsm::MetaModel::Machine mach) {
    //if (token) { // we're coming from a change in text, so don't patch text editor.
    //  println("COMING from text change, not patching term editor");
    //  return;
    //}
    
    termEd = termEditors[myTerm];
    
    if (myModel notin models) {
      models[myModel] = mach;
    }
    
    if (mach == models[myModel]) {
      return;
    }
    
    Patch p = diff(#lang::myfsm::MetaModel::Machine, models[myModel], mach);
    
    println("PATCH from observer");
    iprintln(p);
        
    <model, orgs> = tree2modelWithOrigins(#lang::myfsm::MetaModel::Machine, terms[myTerm], uri=myModel);
    
    models[myModel] = model;
        
    pt2 = patchTree(#lang::myfsm::Syntax::Machine, terms[myTerm], p, orgs, Tree(type[&U<:Tree] tt, str src) {
       return parse(tt, src);
    });
    lrel[loc, str] d = ptDiff(terms[myTerm], pt2);
    println("TEXT DIFF");
    iprintln(d); 
    termEd(d);
    // parse again to get locs right.
    terms[myTerm] = parse(#lang::myfsm::Syntax::Machine, "<pt2>", myTerm);
  };
  
  observeEditor(#lang::myfsm::MetaModel::Machine, myModel, observers[myModel]);
  
  registerLanguage("MyFSM", "mf", lang::myfsm::Syntax::Machine(str src, loc org) {
    lang::myfsm::Syntax::Machine m = parse(#lang::myfsm::Syntax::Machine, src, org);
    
    // save the term
    terms[org] = m;
    
    modelURI = modelLoc(org);
    <model, orgs> = tree2modelWithOrigins(#lang::myfsm::MetaModel::Machine, m, uri=modelURI);
    
    println("MODEL <modelURI>: ");
    iprintln(model);
    
    if (modelURI in models, models[modelURI] == model) {
      return m;
    }
    
    models[modelURI] = model;

    if (modelURI notin modelEditors) {
      modelEditors[modelURI] = editor(#lang::myfsm::MetaModel::Machine, modelURI);
    }

    
    ed = modelEditors[modelURI];
    ed(Patch(lang::myfsm::MetaModel::Machine current) {
      Patch p = diff(#lang::myfsm::MetaModel::Machine, current, models[modelURI]);
      println("CURRENT:");
      iprintln(current);
      println("MODELS table:");
      iprintln(models[modelURI]);
      println("PATCH: ");
      iprintln(p);
      //token = true;
      return p; 
    });
    
    //println("Setting token to false");
    //token = false;
    
    
    
    return m;
  });
  
}