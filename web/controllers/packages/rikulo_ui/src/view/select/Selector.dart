//Copyright (C) 2012 Potix Corporation. All Rights Reserved.
//History: Wed, Jun 06, 2012  12:30:14 AM
// Author: simonpai
part of rikulo_view_select;

class Selector {
  
  final int selectorIndex;
  final List<SimpleSelectorSequence> seqs;
  
  Selector(this.selectorIndex) : seqs = new List<SimpleSelectorSequence>();
  
  void addCombinator(Token token) {
    seqs.last.setCombinatorByToken(token);
  }
  
  int getCombinator(int index) => seqs[index].combinator;
  
  bool requiresIDSpace(int index) => seqs[index].id != null;
  
  SimpleSelectorSequence addSequence() {
    SimpleSelectorSequence seq = new SimpleSelectorSequence();
    seqs.add(seq);
    return seq;
  }
  
  String toString() {
    StringBuffer sb = new StringBuffer();
    for (SimpleSelectorSequence seq in seqs)
      sb.write("$seq${seq.printCombinator()} ");
    return sb.toString().trim();
  }
  
}
