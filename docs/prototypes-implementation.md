# Prototypes and Implementation

## Overview

We have implemented our initial idea in [System Design](system-design.md). Our prototype for our SemanticLLM tool is able to generate basic knowledge graphs from a prompt, and validate that the generated knowledge graph conforms to a given ontology.

Our next steps will be to iterate through potential solutions to the problems we have encountered while using the first prototype.

## Tooling

### Technologies

- Entity Recognition
- Large Language Models
	- Structured Output
- Knowledge graphs
	- KG consistency

  

### Tools
> The parentheses specify what tools make up what components in our [System Design](system-design.md)


- Entity Recognition (Named Entity Recognition)
	- spaCy (en_core_web_lg)
	- Natural language processing library with built in support for named entity recognition 
- Large Language Models (Relation Finder)
	- GPT4o
	- Google Gemini
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
    
Knowledge Graph Visualizer
- Gephi
	- An open source graph visualization tool.

  

### Languages
- Python
- BAML DL

### Development Environment
- VSCode
- Neovim
- Python Virtualenv
- Conda
- GNU + Linux 

## Functionality

We currently have the prototype consistently working for smaller source texts.


#### Example

Find a KG that conforms to an ontology about pizzas.

Source text: Pepperoni Pizza has pepperonni toppings and cheese and red sauce. The 'MegaPizza' contains Cheese and Pepperoni Pizza as toppings"

```turtle
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

Note that although it generated successfully (and ommitted adding pepperoni pizza as a topping as that is invalid from the onology) we would have preferred it reject the input instead of generating one that might be wrong.

## Obstacles and Implementation Issues

As we try to scale the source text up it leads to token limit issues. 

Also, if we need to correct small amounts of the generated knowledge graph it is currently very inefficient, since we re-generate the entire KG.

Sometimes invalid input can produce valid knowledge graphs, we would insted want the LLM to expressly reject the input.