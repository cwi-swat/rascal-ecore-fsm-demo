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
    annotator(lang::myfsm::Syntax::Machine(lang::myfsm::Syntax::Machine input) {
    
     
        // save the term
        println("Saving the term <input@\loc.top>");
        terms[input@\loc.top] = input;
        
        
	    // work relative the modelURI to get XMI correct paths 
	    modelURI = modelLoc(input@\loc);
	    
	    // construct the model corresponding to the source code
	    println("Tree 2 model");
	    <model, orgs> = tree2modelWithOrigins(#lang::myfsm::MetaModel::Machine, input, uri=modelURI);
	    
	    // if no change in terms of the model, just return the parse tree    
	    if (modelURI in models, models[modelURI] == model) {
	      return input;
	    }
	    
		println("Saving the model");
	    models[modelURI] = model;
	
	    // obtain an editor for the model
	    if (modelURI notin modelEditors) {
	      modelEditors[modelURI] = editor(#lang::myfsm::MetaModel::Machine, modelURI);
	    }
	    ed = modelEditors[modelURI];
	
	    println("patching the model");
	    // patch the model editor according to the different between what's currently in there
	    // and the just acquired model from the source code.    
	    ed(Patch(lang::myfsm::MetaModel::Machine current) {
	      // don't patch if there was a parse error.
	      Patch p = diff(#lang::myfsm::MetaModel::Machine, current, models[modelURI]);
	      println("PATCH: ");
	      iprintln(p);
	      return p; 
	    });
	    
	    println("Returning parse tree");
	    return input;
	 })
  });
  
}