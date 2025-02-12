// Defining a raw unit of knowledge.
class Triple {
  subjectIRI string // Should be as generic as possible
  predicateIRI string
  objectIRI string 
}

// Create a function to extract triples from text.
function ExtractTriples(text: string, ontology_file: string) -> Triple[] {
  client "openai/gpt-4o-mini"

  prompt #"
    Using this ontology, generate valid triples from the text.
    
    Ontology:
    {{ ontology_file }}

    Extract from this content:
    {{ text }}

    {{ ctx.output_format }}
  "#
}

// Test the function with a sample resume. Open the VSCode playground to run this.
test wikipedia_bee {
  functions [ExtractTriples]
  args {
    text #"
      Bees are found on every continent except Antarctica, 
      in every habitat on the planet that contains insect-pollinated
      flowering plants.
    "#
  }
}

test john_cena_life {
  functions [ExtractTriples]
  args {
    ontology_file "wikipedia_ontology"
    text #"

    John Felix Anthony Cena was born in West Newbury, Massachusetts, on April 23, 1977, 
    to Carol (née Lupien) and former Chaotic Wrestling ring announcer John Joseph Cena.
    "#
  }
}
