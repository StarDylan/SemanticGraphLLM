// Defining a raw unit of knowledge.
class Triple {
  subjectIRI string // Should be as generic as possible
  predicateIRI string 
  objectIRI string 
}


class FaultyPrompt {
  human_reason string @description(#"
    The text the user gave is unable to be generated such that it conforms to the ontology.
    This is the response we return to the user why its invalid.
  "#)
}


template_string RequirementsMessage() #"
Follow these requirements:
      1) Using the given ontology.
      2) Referencing the entity list as hints. 
      3) Do not use the entity list as the only source of truth, be sure to reference the original text for the source of truth.
      4) When you are done, be sure the last entity is the triple {subjectIRI: "[[DONE]]" predicateIRI: "[[DONE]]" objectIRI: "[[DONE]]"}

Be sure to type all entities with the http://www.w3.org/1999/02/22-rdf-syntax-ns#type predicate.

Be sure that all generated entities are within the base IRI of the ontology.
"#

// Create a function to extract triples from text.
function ExtractTriples(text: string, named_entities: string, ontology_text: string, previous_triples: Triple[]) -> Triple[] {
  client Gemini

  prompt #"
    You need to generate valid triples from the text.
    
    {{ RequirementsMessage() }}

    Ontology:
    {{ ontology_text }}

    Entities:
    {{ named_entities }}

    Extract from this content (Original Text):
    {{ text }}

    {{ ctx.output_format }}

    {% if previous_triples %}
      Here are the triples you generated before, do not repeat them, instead build on them:
      {% for triple in previous_triples %}
        {{ triple.subjectIRI }} {{ triple.predicateIRI }} {{ triple.objectIRI }}
      {% endfor %}
    {% endif %}

  "#
}


function RetryTriples(old_triples: string, reasoner_failed_reason: string, text: string, named_entities: string, ontology_text: string) -> Triple[] | FaultyPrompt {
  client Gemini

  prompt #"
    The ontology verifier said that the triples you generated were invalid.
    Please correct the triples to conform to the ontology or provide a 
    reason why the original text does not comform to the ontology.

    This is your task that failed:
    {{ RequirementsMessage() }}

    Here is the reason why the triples failed:
    {{ reasoner_failed_reason }}

    Failed Triples:
    {{ old_triples }}

    Ontology:
    {{ ontology_text }}

    Entities:
    {{ named_entities }}

    Extract from this content (Original Text):
    {{ text }}  

    {{ ctx.output_format }}
  "#
}


test invalid_pizza_ontology {
  functions [ExtractTriples]
  args {
    ontology_text #"
    <?xml version="1.0"?>
    <rdf:RDF xmlns="http://www.semanticweb.org/dylan/ontologies/2025/1/untitled-ontology-2/"
         xml:base="http://www.semanticweb.org/dylan/ontologies/2025/1/untitled-ontology-2/"
         xmlns:owl="http://www.w3.org/2002/07/owl#"
         xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
         xmlns:xml="http://www.w3.org/XML/1998/namespace"
         xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
         xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
         xmlns:untitled-ontology-2="http://www.semanticweb.org/dylan/ontologies/2025/1/untitled-ontology-2#">
        <owl:Ontology rdf:about="http://www.semanticweb.org/dylan/ontologies/2025/1/untitled-ontology-2"/>
        
    
    
        <!-- 
        ///////////////////////////////////////////////////////////////////////////////////////
        //
        // Object Properties
        //
        ///////////////////////////////////////////////////////////////////////////////////////
         -->
    
        
    
    
        <!-- http://www.semanticweb.org/dylan/ontologies/2025/1/untitled-ontology-2#hasTopping -->
    
        <owl:ObjectProperty rdf:about="http://www.semanticweb.org/dylan/ontologies/2025/1/untitled-ontology-2#hasTopping">
            <rdfs:domain rdf:resource="http://www.semanticweb.org/dylan/ontologies/2025/1/untitled-ontology-2#Pizza"/>
            <rdfs:range rdf:resource="http://www.semanticweb.org/dylan/ontologies/2025/1/untitled-ontology-2#Ingredient"/>
        </owl:ObjectProperty>
        
    
    
        <!-- 
        ///////////////////////////////////////////////////////////////////////////////////////
        //
        // Classes
        //
        ///////////////////////////////////////////////////////////////////////////////////////
         -->
    
        
    
    
        <!-- http://www.semanticweb.org/dylan/ontologies/2025/1/untitled-ontology-2#Ingredient -->
    
        <owl:Class rdf:about="http://www.semanticweb.org/dylan/ontologies/2025/1/untitled-ontology-2#Ingredient">
            <owl:disjointWith rdf:resource="http://www.semanticweb.org/dylan/ontologies/2025/1/untitled-ontology-2#Pizza"/>
        </owl:Class>
        
    
    
        <!-- http://www.semanticweb.org/dylan/ontologies/2025/1/untitled-ontology-2#Pizza -->
    
        <owl:Class rdf:about="http://www.semanticweb.org/dylan/ontologies/2025/1/untitled-ontology-2#Pizza"/>
    
    </rdf:RDF>
    
    
    
    <!-- Generated by the OWL API (version 4.5.29.2024-05-13T12:11:03Z) https://github.com/owlcs/owlapi -->
    "#

    named_entities "MegaPizza, Pepperoni, Pizza, toppings, cheese, sauce, MegaPizza, Cheese, Pizza, Pepperoni, Pizza, toppings"

    text #"
      Pepperoni Pizza has pepperonni toppings and cheese and red sauce. The 'MegaPizza' contains Cheese Pizza and Pepperoni Pizza as toppings
    "#
  }
}


test retry_pizza_ontology {
  functions [RetryTriples]
  args {
    reasoner_failed_reason "The triples generated were invalid because the object of the hasTopping predicate must be of type Ingredient."

    old_triples #"
    [
      {
        "subjectIRI": "http://www.semanticweb.org/dylan/ontologies/2025/1/untitled-ontology-2#PepperoniPizza",
        "predicateIRI": "http://www.semanticweb.org/dylan/ontologies/2025/1/untitled-ontology-2#hasTopping",
        "objectIRI": "http://www.semanticweb.org/dylan/ontologies/2025/1/untitled-ontology-2#Pepperoni"
      },
      {
        "subjectIRI": "http://www.semanticweb.org/dylan/ontologies/2025/1/untitled-ontology-2#PepperoniPizza",
        "predicateIRI": "http://www.semanticweb.org/dylan/ontologies/2025/1/untitled-ontology-2#hasTopping",
        "objectIRI": "http://www.semanticweb.org/dylan/ontologies/2025/1/untitled-ontology-2#cheese"
      },
      {
        "subjectIRI": "http://www.semanticweb.org/dylan/ontologies/2025/1/untitled-ontology-2#PepperoniPizza",
        "predicateIRI": "http://www.semanticweb.org/dylan/ontologies/2025/1/untitled-ontology-2#hasTopping",
        "objectIRI": "http://www.semanticweb.org/dylan/ontologies/2025/1/untitled-ontology-2#sauce"
      },
      {
        "subjectIRI": "http://www.semanticweb.org/dylan/ontologies/2025/1/untitled-ontology-2#MegaPizza",
        "predicateIRI": "http://www.semanticweb.org/dylan/ontologies/2025/1/untitled-ontology-2#hasTopping",
        "objectIRI": "http://www.semanticweb.org/dylan/ontologies/2025/1/untitled-ontology-2#CheesePizza"
      },
      {
        "subjectIRI": "http://www.semanticweb.org/dylan/ontologies/2025/1/untitled-ontology-2#MegaPizza",
        "predicateIRI": "http://www.semanticweb.org/dylan/ontologies/2025/1/untitled-ontology-2#hasTopping",
        "objectIRI": "http://www.semanticweb.org/dylan/ontologies/2025/1/untitled-ontology-2#PepperoniPizza"
      },
      {
        "subjectIRI": "http://www.semanticweb.org/dylan/ontologies/2025/1/untitled-ontology-2#PepperoniPizza",
        "predicateIRI": "http://www.w3.org/1999/02/22-rdf-syntax-ns#type",
        "objectIRI": "http://www.semanticweb.org/dylan/ontologies/2025/1/untitled-ontology-2#Pizza"
      },
      {
        "subjectIRI": "http://www.semanticweb.org/dylan/ontologies/2025/1/untitled-ontology-2#MegaPizza",
        "predicateIRI": "http://www.w3.org/1999/02/22-rdf-syntax-ns#type",
        "objectIRI": "http://www.semanticweb.org/dylan/ontologies/2025/1/untitled-ontology-2#Pizza"
      },
      {
        "subjectIRI": "http://www.semanticweb.org/dylan/ontologies/2025/1/untitled-ontology-2#CheesePizza",
        "predicateIRI": "http://www.w3.org/1999/02/22-rdf-syntax-ns#type",
        "objectIRI": "http://www.semanticweb.org/dylan/ontologies/2025/1/untitled-ontology-2#Pizza"
      },
      {
        "subjectIRI": "http://www.semanticweb.org/dylan/ontologies/2025/1/untitled-ontology-2#Pepperoni",
        "predicateIRI": "http://www.w3.org/1999/02/22-rdf-syntax-ns#type",
        "objectIRI": "http://www.semanticweb.org/dylan/ontologies/2025/1/untitled-ontology-2#Ingredient"
      },
      {
        "subjectIRI": "http://www.semanticweb.org/dylan/ontologies/2025/1/untitled-ontology-2#cheese",
        "predicateIRI": "http://www.w3.org/1999/02/22-rdf-syntax-ns#type",
        "objectIRI": "http://www.semanticweb.org/dylan/ontologies/2025/1/untitled-ontology-2#Ingredient"
      },
      {
        "subjectIRI": "http://www.semanticweb.org/dylan/ontologies/2025/1/untitled-ontology-2#sauce",
        "predicateIRI": "http://www.w3.org/1999/02/22-rdf-syntax-ns#type",
        "objectIRI": "http://www.semanticweb.org/dylan/ontologies/2025/1/untitled-ontology-2#Ingredient"
      }
    ]
    "#

    reasoner_failed_reason #"Axiom: Thing subClassOf Nothing

    Explanation(s): 
    1)   hasTopping range Ingredient
         PepperoniPizza type Pizza
         Ingredient disjointWith Pizza
         MegaPizza hasTopping PepperoniPizza"#

    prompt #"
    The ontology verifier said that the triples you generated were invalid.
    Please correct the triples to conform to the ontology or provide a 
    reason why the original text does not comform to the ontology.

    This is your task that failed:
    {{ RequirementsMessage() }}

    Here is the reason why the triples failed:
    {{ reasoner_failed_reason }}

    Failed Triples:
    {{ old_triples }}

    Ontology:
    {{ ontology_text }}

    Entities:
    {{ named_entities }}

    Extract from this content (Original Text):
    {{ text }}  

    {{ ctx.output_format }}
  "#
    ontology_text #"
    <?xml version="1.0"?>
    <rdf:RDF xmlns="http://www.semanticweb.org/dylan/ontologies/2025/1/untitled-ontology-2/"
         xml:base="http://www.semanticweb.org/dylan/ontologies/2025/1/untitled-ontology-2/"
         xmlns:owl="http://www.w3.org/2002/07/owl#"
         xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
         xmlns:xml="http://www.w3.org/XML/1998/namespace"
         xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
         xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
         xmlns:untitled-ontology-2="http://www.semanticweb.org/dylan/ontologies/2025/1/untitled-ontology-2#">
        <owl:Ontology rdf:about="http://www.semanticweb.org/dylan/ontologies/2025/1/untitled-ontology-2"/>
        
    
    
        <!-- 
        ///////////////////////////////////////////////////////////////////////////////////////
        //
        // Object Properties
        //
        ///////////////////////////////////////////////////////////////////////////////////////
         -->
    
        
    
    
        <!-- http://www.semanticweb.org/dylan/ontologies/2025/1/untitled-ontology-2#hasTopping -->
    
        <owl:ObjectProperty rdf:about="http://www.semanticweb.org/dylan/ontologies/2025/1/untitled-ontology-2#hasTopping">
            <rdfs:domain rdf:resource="http://www.semanticweb.org/dylan/ontologies/2025/1/untitled-ontology-2#Pizza"/>
            <rdfs:range rdf:resource="http://www.semanticweb.org/dylan/ontologies/2025/1/untitled-ontology-2#Ingredient"/>
        </owl:ObjectProperty>
        
    
    
        <!-- 
        ///////////////////////////////////////////////////////////////////////////////////////
        //
        // Classes
        //
        ///////////////////////////////////////////////////////////////////////////////////////
         -->
    
        
    
    
        <!-- http://www.semanticweb.org/dylan/ontologies/2025/1/untitled-ontology-2#Ingredient -->
    
        <owl:Class rdf:about="http://www.semanticweb.org/dylan/ontologies/2025/1/untitled-ontology-2#Ingredient">
            <owl:disjointWith rdf:resource="http://www.semanticweb.org/dylan/ontologies/2025/1/untitled-ontology-2#Pizza"/>
        </owl:Class>
        
    
    
        <!-- http://www.semanticweb.org/dylan/ontologies/2025/1/untitled-ontology-2#Pizza -->
    
        <owl:Class rdf:about="http://www.semanticweb.org/dylan/ontologies/2025/1/untitled-ontology-2#Pizza"/>
    
    </rdf:RDF>
    
    
    
    <!-- Generated by the OWL API (version 4.5.29.2024-05-13T12:11:03Z) https://github.com/owlcs/owlapi -->
    "#

    named_entities "MegaPizza, Pepperoni, Pizza, toppings, cheese, sauce, MegaPizza, Cheese, Pizza, Pepperoni, Pizza, toppings"

    text #"
      Pepperoni Pizza has pepperonni toppings and cheese and red sauce. The 'MegaPizza' contains Cheese Pizza and Pepperoni Pizza as toppings
    "#

  }
}



test retry_correct_pizza_ontology {
  functions [ExtractTriples]
  args {
    ontology_text #"
    <?xml version="1.0"?>
    <rdf:RDF xmlns="http://www.semanticweb.org/dylan/ontologies/2025/1/untitled-ontology-2/"
         xml:base="http://www.semanticweb.org/dylan/ontologies/2025/1/untitled-ontology-2/"
         xmlns:owl="http://www.w3.org/2002/07/owl#"
         xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
         xmlns:xml="http://www.w3.org/XML/1998/namespace"
         xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
         xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
         xmlns:untitled-ontology-2="http://www.semanticweb.org/dylan/ontologies/2025/1/untitled-ontology-2#">
        <owl:Ontology rdf:about="http://www.semanticweb.org/dylan/ontologies/2025/1/untitled-ontology-2"/>
        
    
    
        <!-- 
        ///////////////////////////////////////////////////////////////////////////////////////
        //
        // Object Properties
        //
        ///////////////////////////////////////////////////////////////////////////////////////
         -->
    
        
    
    
        <!-- http://www.semanticweb.org/dylan/ontologies/2025/1/untitled-ontology-2#hasTopping -->
    
        <owl:ObjectProperty rdf:about="http://www.semanticweb.org/dylan/ontologies/2025/1/untitled-ontology-2#hasTopping">
            <rdfs:domain rdf:resource="http://www.semanticweb.org/dylan/ontologies/2025/1/untitled-ontology-2#Pizza"/>
            <rdfs:range rdf:resource="http://www.semanticweb.org/dylan/ontologies/2025/1/untitled-ontology-2#Ingredient"/>
        </owl:ObjectProperty>
        
    
    
        <!-- 
        ///////////////////////////////////////////////////////////////////////////////////////
        //
        // Classes
        //
        ///////////////////////////////////////////////////////////////////////////////////////
         -->
    
        
    
    
        <!-- http://www.semanticweb.org/dylan/ontologies/2025/1/untitled-ontology-2#Ingredient -->
    
        <owl:Class rdf:about="http://www.semanticweb.org/dylan/ontologies/2025/1/untitled-ontology-2#Ingredient">
            <owl:disjointWith rdf:resource="http://www.semanticweb.org/dylan/ontologies/2025/1/untitled-ontology-2#Pizza"/>
        </owl:Class>
        
    
    
        <!-- http://www.semanticweb.org/dylan/ontologies/2025/1/untitled-ontology-2#Pizza -->
    
        <owl:Class rdf:about="http://www.semanticweb.org/dylan/ontologies/2025/1/untitled-ontology-2#Pizza"/>
    
    </rdf:RDF>
    
    
    
    <!-- Generated by the OWL API (version 4.5.29.2024-05-13T12:11:03Z) https://github.com/owlcs/owlapi -->
    "#

    named_entities "MegaPizza, Pepperoni, Pizza, toppings, cheese, sauce, MegaPizza, Cheese, Pizza, Pepperoni, Pizza, toppings"

    text #"
      Pepperoni Pizza has pepperonni toppings and cheese and red sauce. The 'MegaPizza' contains Cheese and Pepperoni as toppings
    "#
  }
}
