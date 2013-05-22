//Copyright (C) 2012 Potix Corporation. All Rights Reserved.
//History: Wed, Jun 06, 2012  12:30:14 AM
// Author: simonpai
part of rikulo_view_select;

class SimpleSelectorSequence {
  
  String type;
  String id;
  final Set<String> classes;
  final List<Attribute> attributes;
  final List<PseudoClass> pseudoClasses;
  int combinator = COMB_DESCENDANT;
  
  SimpleSelectorSequence() : 
    classes = new Set<String>(),
    attributes = new List<Attribute>(),
    pseudoClasses = new List<PseudoClass>();
  
  // setters: only once
  
  void setCombinatorByToken(Token token) {
    //if (combinator != COMB_DESCENDANT) // TODO: parse exception
    switch (token.type) {
      case Token.TYPE_CBN_CHILD:
        this.combinator = COMB_CHILD;
        break;
      case Token.TYPE_CBN_ADJACENT_SIBLING:
        this.combinator = COMB_ADJACENT_SIBLING;
        break;
      case Token.TYPE_CBN_GENERAL_SIBLING:
        this.combinator = COMB_GENERAL_SIBLING;
        break;
      default:
        // TODO: parse exception
    }
  }
  
  //Attribute _currAttr;
  //PseudoClass _currPseudoCls;
  
  static const int COMB_DESCENDANT = 0; //
  static const int COMB_CHILD = 1; // >
  static const int COMB_ADJACENT_SIBLING = 2; // +
  static const int COMB_GENERAL_SIBLING = 3; // ~
  
  String printCombinator() {
    switch (this.combinator) {
      case COMB_CHILD:
        return " >";
      case COMB_ADJACENT_SIBLING:
        return " +";
      case COMB_GENERAL_SIBLING:
        return " ~";
      default:
        return "";
    }
  }
  
  String toString() {
    StringBuffer sb = new StringBuffer();
    if (type != null)
      sb.write(type);
    if (id != null)
      sb.write("#${id}");
    for (String c in classes)
      sb.write(".${c}");
    for (PseudoClass p in pseudoClasses)
      sb.write("${p}");
    return sb.isEmpty ? "*" : sb.toString();
  }
  
}
