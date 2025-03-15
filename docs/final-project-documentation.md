# LLMs for Semantic Web

By Dylan Starink and Benjamin Hinchliff

**Advisor**: Dr. Kurfess
**Course**: CSC 581 Winter 2025
**Affiliation**: Cal Poly San Luis Obispo, Computer Science and Software Engineering Department
**Completion Date**: 3/14/2025

## Abstract

The Semantic Web failed because it required large amounts of manual labor to label information correctly. LLMs are a relatively novel technique for processing language data and may provide a better route to provide semantic meaning to text. Therefore, our project created a framework and system to generate knowledge graphs of arbitrary text in a robust way.

# Overview

With this project, we aim to create a system that produces a knowledge graph of useful information and relations from natural language using recent advancements in LLMs (e.g. LLaMA). This should conform to standard ontologies where applicable with the option of custom ontologies being available should it be necessary. We also aim to allow the merging of multiple knowledge graphs generated from different sources on a subject to unify information.

The semantic web has been largely a failure due to the amount of human labor required to transform natural language into knowledge graphs of standard ontologies. We contend that a semi-automated system utilizing LLMs for the majority of the syntax generation and labor would allow for more sites to be integrated into the Linked Open Data Cloud as well as increasing data uniformity and their ability to be queried.

We envision our users to be anyone who would like to run structured queries against some text. This includes people who want to explore certain areas of a text without reading the whole project.
# Background & Related Work

Some similar techniques already exist for creating knowledge graphs for use alongside LLMs, similar to RAG. They ask the LLM to generate a structured json output of subject, predicate and object. This leads to very flexible graphs, but they don’t allow for the user to perform advanced structured queries easily [1].


In addition, other architectures have been proposed such as the AutoKG [2], however they’ve not been tested extensively. They propose an Agentic architecture with communication between a knowledge graph user and assistant, both AI models, as seen in figure 1. With the current state of the art, other deep learning techniques currently beat out LLM methods [3], where traditional methods of named entity recognition and relation extraction are utilized, outperforming GPT-4 with basic prompting in their testing.

![Illustration of AutoKG architecture](assets/autokg.png)


Figure 1: illustration of proposed AutoKG architecture [2].
# Features and Requirements

### Features
- Generates Meaningful Knowledge Graphs from natural language that conforms to the ontology.
- Works with any OWL-DL Ontology.

### Requirements
- The system takes as input an ontology in OWL-DL and a text blob encapsulating the facts wanting to be represented in the knowledge graph.
- The system outputs a knowledge graph in RDF serialized as turtle.
- The generated knowledge graph should encapsulate all facts relevant to the ontology.
- The resulting knowledge graph should conform to the ontology specified.

### Evaluation Criteria
- Does the generated output conform to turtle syntax?
- What proportion of entities and relationships that match the ontology?
- What proportion of facts in the text are captured by the knowledge graph? (compared to facts as evaluated by a human operator)


# System Design

```
+------------------+              +--------------------------+
|                  |------------->| Named Entity Recognition |
| Natural Language |              +--------------------------+
|                  |--------------------+ |
+------------------+                    | |
+------------------+                    | |
|    Ontology      |------------------+ | |
+------------------+                  | | |
         |                            v v v
         |                    +---------------------+
         |                    |   Relation Finder   |<--------+
         |                    +---------------------+         |
         |                              |                     |
         |                              |                     |
         |                              |                     | Reject
         |                              |                     |
         |                              v                     |
         |                    +---------------------+         |
         +------------------->|  Ontology Verifier  |---------+
                              +---------------------+
                                        |
                                        | Accept
                                        v
                                +----------------+
                                | Return to User |
                                +----------------+
```
## Overview

The system takes as input the natural language text and the ontology that the final knowledge graph should conform to. The current plan is to feed natural language into a Named Entity Recognition (NER) system, which will (ideally) serve to extract important entities from the text. After this, the entities, natural language, and ontology, are all fed into the Relation Finder, which attempts to find relations between the entities which conform to the ontology. This is then passed to an ontology verifier, which confirms whether it conforms to the ontology. If it doesn't conform, it's rejected and the Relation Finder is run again with feedback from the verifier. Otherwise, the generated knowledge graph is returned to the user.

  

## System Components

Natural Language - The source text that contains knowledge we wish to create a Knowledge Graph from.

Ontology - The "schema" of the knowledge graph we wish to create.

Named Entity Recognition - Finds proper nouns in the text.

Relation Finder - Determines the relations between entities in the text and ontology. Currently this is achieved with Google Gemini 1.5 Flash and appending the Ontology, and source text. On retries (on failure from the Ontology Verifier) we also append any feedback from the ontology verifier and the old generated response. We tie all of these together with a [prompt written here](https://github.com/StarDylan/SemanticGraphLLM/blob/main/baml_src/relation_gen.baml).

Ontology Verifier - Determines if the generated knowledge graph conforms to the ontology. This is achieved with an off-the-shelf program, Pellet.

Return To User - Returns the generated knowledge graph.

  

## Model + Data Structures

Knowledge from the source text is represented in RDF triples. Which contain three parts: a subject, a predicate, and an object. Each of these is represented by an IRI (we have not implemented blank nodes or literals). The knowledge graph is simply an array of these triples.

# Implementation

The system we’ve built is a cli application that can be found in kgllm.py. When invoked with `python kgllm.py` it takes as input a text file (the text blob) along with an optional ontology specified by the `-t` flag, in line with the requirements. See the full code [here](https://github.com/StarDylan/SemanticGraphLLM)

## Technologies
- Entity Recognition
- Large Language Models
- Structured Output
- Knowledge graphs
- KG consistency
## Tools

The parentheses specify what tools make up what components in our [System Design](https://github.com/StarDylan/SemanticGraphLLM/blob/main/docs/system-design.md)

- Entity Recognition (Named Entity Recognition)
	- spaCy (en_core_web_lg)
		- Natural language processing library with built in support for named entity recognition 
- Large Language Models (Relation Finder)
	- **Google Gemini 1.5 Flash** (primary)
	- GPT4o
	- Deepseek-R1 8B
- Structured Output / LLM Library
	- BAML
		- LLM structured output library that uses a flexible JSON (BAML-DL) variant to generously parse LLM output into structured form
- Knowledge Graphs (+ Ontology)
	- Owlready2 (Python Library)
		- Ontology and knowledge graph generation tool, providing data structures for constructing and manipulating KGs
	- Rdflib (Python Library)
		- Provides a view on the KG that allows us to serialize it easily to CSV (a format which Gephi can easily import)
		
- Knowledge Graph Reasoner (Ontology Verifier)
	- Pellet
		- Used to check if a generated knowledge graph is consistent with the ontology.
    
- Knowledge Graph Visualizer
	- Gephi
		- An open source graph visualization tool used to visualize the finished knowledge graph.
## Languages
- Python
- BAML DL

## Development Environment
- VSCode
- Neovim
- Python Virtualenv
- Conda
- GNU + Linux 

## Example

Find a KG that conforms to an ontology about pizzas.

Source text: Pepperoni Pizza has pepperonni toppings and cheese and red sauce. The 'MegaPizza' contains Cheese and Pepperoni Pizza as toppings"

Invocation: `python kgllm.py -l ontologies/pizza_ontology.owl data/pizza.txt -v`

```
:MegaPizza a :Pizza ;
    :hasTopping :Cheese .
 
:PepperoniPizza a :Pizza ;
    :hasTopping :Cheese,
        :Pepperoni,
        :RedSauce .

:Pepperoni a :Ingredient .
:RedSauce a :Ingredient .
:Cheese a :Ingredient .
```

Note that although it generated successfully (and omitted adding pepperoni pizza as a topping as that is invalid from the ontology) we would have preferred it reject the input instead of generating one that might be wrong.

# Evaluation on Requirements

Being a system that operates heavily in the realm of ephemeral concepts such as capturing all facts of a text, our system is naturally difficult to evaluate. With that said, we evaluated our program on the [markdown file here](https://github.com/StarDylan/SemanticGraphLLM/blob/main/data/big-pizza.md) and the [ontology here](https://github.com/StarDylan/SemanticGraphLLM/blob/main/ontologies/pizza_ontology.owl). This was a large dataset that very much stressed our system past its limits.

## Requirement Fulfillment and Caveats

- The system outputs RDF serialized both as XML (for compatibility with the pellet reasoner) and as turtle, in line with requirements

- The system is quite good at extracting relevant facts on smaller ontologies, achieving a fact capture ratio of 100% on smaller examples, such as a single sentence describing a pizza, but struggles with scaling up to larger examples. This can be seen with our evaluation on `big-pizza.md`, a mock pizza 80s themed pizza menu of 50 pizzas. Out of the 50 total pizzas described in the markdown file, only 18 were captured in the final knowledge graph. And from the 38 ingredients that were present in the original data only 20 of them were captured in the final knowledge graph. Lastly, from the about 200 “hasTopping” relationships about 46 were captured in the knowledge graph. For this example the total proportion of entities and relationships captured was only about 30%.

- The system incorporates a knowledge graph reasoner, Pellet, that ensures that any output from the system must conform to the ontology, or otherwise be rejected. Thus every knowledge graph generated fully conforms to the ontology.
  

# Relevance for AI

As mentioned in the overview, creation of knowledge graphs from existing knowledge in other forms, typically natural language, has long been the Achilles heel of endeavors like the semantic web and large scale usage of knowledge graphs as a whole, due to the high labor requirements. Our system aims to improve those requirements and in so doing allow the usage for knowledge graphs more widely, including their many applications in both symbolic and neural AI systems.

# Lessons Learned and Future Work

Our system performs well with small inputs but struggles with larger ontologies and source texts. While this is encouraging, further development is necessary for real-world applications.

A potential next step is to decompose the "Relation Finder" component. Specifically, we could first extract new entities (with IRIs) and then incrementally add relations, rather than handling everything in a single step. Currently, the Named Entity Recognition system provides hints for potential entities, but these are often inaccurate. This step-by-step approach aligns with our observation that smaller prompts yield better results.

Furthermore, reducing the output token count could enhance efficiency, as the current method requires the Relation Finder to output the full IRI for each triple, which is highly inefficient.

Lastly, the concept behind larger ontologies isn’t always immediately obvious, such as with the friend-of-a-friend (FOAF) ontology, where we know as humans the ontology is about relations between people, but that information is easily lost to the LLM for an ontology of such a large size. Summarizing that, semantic meaning might help yield better results when using the system with large ontologies.

If pursed, these avenues could create a system better able to capture facts and perform to the level needed to significantly reduce the labor of Knowledge Graph creation.

# References

[1] “How to construct knowledge graphs.” https://python.langchain.com/docs/how_to/graph_constructing/.

[2] Y. Zhu et al., “LLMS for knowledge graph construction and reasoning: Recent capabilities and future opportunities,” World Wide Web, vol. 27, no. 5, Aug. 2024. doi:10.1007/s11280-024-01297-w

[3] H. Ye, N. Zhang, H. Chen, and H. Chen, “Generative Knowledge Graph Construction: A Review,” Proceedings of the 2022 Conference on Empirical Methods in Natural Language Processing, Dec. 2022. doi:10.18653/v1/2022.emnlp-main.1
