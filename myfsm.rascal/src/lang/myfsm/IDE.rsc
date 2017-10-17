module lang::myfsm::IDE

import lang::myfsm::Syntax;
import lang::ecore::text::Tree2Model;
import lang::ecore::text::PatchTree;
import lang::ecore::text::PTDiff;
import lang::ecore::IO;
import lang::ecore::diff::Diff;
import lang::myfsm::MetaModel;

import util::IDE;
import ParseTree;
import Message;
import IO;



void main() {
  map[loc, void(lang::myfsm::MetaModel::Machine)] observers = ();
  
  map[loc, void(Patch)] modelEditors = ();
  map[loc, void(lrel[loc, str])] termEditors = ();
  
  map[loc, lang::myfsm::MetaModel::Machine] models = ();
  map[loc, lang::myfsm::Syntax::Machine] terms = ();
  
  loc modelLoc(loc l) = l[extension="myfsm"];
  
  
  myModel = |project://TestIt/src/doors.myfsm|;
  myTerm = myModel[extension="mf"];
  termEditors[myTerm] = termEditor(myModel[extension="mf"]);
  
  // NB: all trees are non-top now...
  observers[myModel] = void(lang::myfsm::MetaModel::Machine mach) {
    
    // if no change, do nothing
    if (myModel in models, mach == models[myModel]) {
      println("No change between model in model editor and current");
      return;
    }

    // mach is now the current model
    println("Saving current model from model editor");    
    models[myModel] = mach;    
    
    if (myTerm notin terms) {
      println("No term <myTerm>");
      return;
    }
    
    // build the model conforming to the current source code        
    <model, orgs> = tree2modelWithOrigins(#lang::myfsm::MetaModel::Machine, terms[myTerm], uri=myModel);

    // compute the diff between model from text, and current model
    Patch p = diff(#lang::myfsm::MetaModel::Machine, model, models[myModel]);
    
    println("PATCH from observer");
    iprintln(p);

    // patch the original source code according to patch p    
    println("Patching tree according to patch");
    pt2 = patchTree(#lang::myfsm::Syntax::Machine, terms[myTerm], p, orgs, Tree(type[&U<:Tree] tt, str src) {
       return parse(tt, src);
    });
    
    // parse again to get locs right.
    pt2 = parse(#lang::myfsm::Syntax::Machine, "<pt2>", myTerm);

    
    
    // compute the textual diff between the old parse tree and the patched one
    println("Computing text diff");
    lrel[loc, str] d = ptDiff(terms[myTerm], pt2);
    
    println("TEXT DIFF");
    iprintln(d); 
    
    // the patched tree is now the current one.
    println("Saving new parse tree");
    terms[myTerm] = pt2;
    
    
    // update the editor
    println("Updating the editor");
    termEd = termEditors[myTerm];
    termEd(d);
    
  };
  
  observeEditor(#lang::myfsm::MetaModel::Machine, myModel, observers[myModel]);
  
  registerLanguage("MyFSM", "mf", lang::myfsm::Syntax::Machine(str src, loc org) {
    return parse(#lang::myfsm::Syntax::Machine, src, org);
  });
  
  registerContributions("MyFSM", {
    builder(set[Message] (lang::myfsm::Syntax::Machine input) {
     
        // save the term
        println("Saving the term <myTerm>");
        terms[myTerm] = input;
        
        
	    // construct the model corresponding to the source code
	    println("Tree 2 model");
	    <model, orgs> = tree2modelWithOrigins(#lang::myfsm::MetaModel::Machine, input, uri=myModel);
	    
	    // if no change in terms of the model, just return the parse tree    
	    if (myModel in models, models[myModel] == model) {
	      return {};
	    }
	    
		println("Saving the model");
		old = models[myModel];
	    models[myModel] = model;
	
	    // obtain an editor for the model
	    if (myModel notin modelEditors) {
	      modelEditors[myModel] = modelEditor(myModel);
	    }
	    
	    Patch p = diff(#lang::myfsm::MetaModel::Machine, old, models[myModel]);
	    println("PATCH: ");
	    iprintln(p);
	      
	    println("patching the model");
	    ed = modelEditors[myModel];
 		ed(p);	    
	    
	    
	    println("Returning OK");
	    return {};
	 })
  });
  
}