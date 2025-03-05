## Evaluation Plan
We will run our program on one or more sufficiently large input documents and will rate the performance of the program on these criteria:

- Does the generated output conform to turtle syntax?

- What proportion of entities and relationships that match the ontology?

- What proportion of facts in the text are captured by the knowledge graph? (compared to facts as evaluated by a human operator)

- (Stretch Goal) Does the system duplicate data when integrating with an existing knowledge graph?

## Mapping of Features to Requirements

| High-Level Features                                                                        | Lower-Level Requirements                                                                                                                  |
| ------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------- |
| Generates Meaningful Knowledge Graphs from natural language that conforms to the ontology. | The system takes as input an ontology in OWL-DL and a text blob encapsulating the facts wanting to be represented in the knowledge graph. |
|                                                                                            | The system outputs a knowledge graph in RDF serialized as turtle.                                                                         |
| Works with any OWL-DL Ontology.                                                            | The generated knowledge graph should encapsulate all facts relevant to the ontology.                                                      |
|                                                                                            | The resulting knowledge graph should conform to the ontology specified.                                                                   |
| (Stretch goal) Add nodes / relationships into existing KGs.                                | (Stretch goal) The knowledge graph should be able to read/write facts in neo4j or other similar graph database.                           |

## Usage of Evaluation Criteria

Currently, our first evaluation criterion is met because all output from the system is verified by an OWL reasoning system. Additionally, the LLM output is constrained to JSON syntax, ensuring that the system can either produce a valid knowledge graph or result in an error.

The two human-based metrics require extensive human labor and so are being delayed until the system is more-or-less finalized. From preliminary results, however, we expect the system to do quite well on straightforward passages.

Stretch goals have not yet been met, and likely will not be met within the timeframe due to both time and technical constraints

## Overall Assessment

Overall we are quite satisfied with the performance of the SemanticGraphLLM project. Moving forward we will continue to test with varied ontologies, dataset sizing, and source text clarity in order to get a good grasp on the capabilities of the project.