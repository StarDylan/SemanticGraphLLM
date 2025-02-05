# System Design and Architecture

```
+------------------+              +--------------------------+
|                  |------------->| Named Entity Recognition |
| Natural Language |              +--------------------------+
|                  |--------------------+ |
+------------------+                    | |
+------------------+                    | |
|    Ontology      |------------------+ | |
+------------------+                  | | |
         |                            v v v
         |                    +---------------------+
         |                    |   Relation Finder   |<--------+
         |                    +---------------------+         |
         |                              |                     |
         |                              |                     |
         |                              |                     | Reject
         |                              |                     |
         |                              v                     |
         |                    +---------------------+         |
         +------------------->|  Ontology Verifier  |---------+
                              +---------------------+
                                        |
                                        | Accept
                                        v
                                +----------------+
                                | Return to User |
                                +----------------+
```


## Overview

The system takes as input the natural language text and the ontology that the
final knowledge graph should conform to. The current plan is to feed natural
language into a Named Entity Recognition (NER) system, which will (ideally)
serve to extract important entities from the text. After this, the entities,
natural language, and ontology, are all fed into the Relation Finder, which
attempts to find relations between the entities which conform to the ontology.
This is then passed to an ontology verifier, which confirms whether it conforms
to the ontology. If it doesn't conform, it's rejected and the Relation Finder is
run again with feedback from the verifier. Otherwise, the generated knowledge
graph is returned to the user.

## System Components

**Natural Language** - The source text that contains knowledge we wish to create
a Knowledge Graph from.

**Ontology** - The "schema" of the knowledge graph we wish to create.

**Named Entity Recognition** - Finds proper nouns in the text.

**Relation Finder** - Determines the relations between entities in the text
and ontology.

**Ontology Verifier** - Determines if the generated knowledge graph conforms
to the ontology.

**Return To User** - Returns the generated knowledge graph.
