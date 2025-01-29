
# Features
- Generates Meaningful Knowledge Graphs from natural language that conforms to the ontology.
- Works with any OWL-DL Ontology.
- (Stretch goal) Add nodes / relationships into existing KGs.

# Requirements

- The system takes as input an ontology in OWL-DL and a text blob encapsulating the facts wanting to be represented in the knowledge graph.
- The system outputs a knowledge graph in RDF serialized as turtle.
- The generated knowledge graph should encapsulate all facts relevant to the ontology.
- The resulting knowledge graph should conform to the ontology specified.
- (Stretch goal) The knowledge graph should be able to read/write facts in neo4j or other similar graph database.

# Evaluation Criteria
- Does the generated output conform to turtle syntax?
- What proportion of entities and relationships that match the ontology?
- What proportion of facts in the text are captured by the knowledge graph? (compared to facts as evaluated by a human operator)
- (Stretch Goal) Does the system duplicate data when integrating with an existing knowledge graph?
