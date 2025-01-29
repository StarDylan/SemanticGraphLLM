// Defining a raw unit of knowledge.
class Triple {
  subject string // Should be as generic as possible
  predicate string
  object string @description(#"
    Should be as generic as possible to allow for linking with
    other triples.
  "#)
}

// Create a function to extract triples from text.
function ExtractTriples(text: string) -> Triple[] {
  client Deepseek
  prompt #"
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
    text #"

    John Felix Anthony Cena was born in West Newbury, Massachusetts, on April 23, 1977, 
    to Carol (née Lupien) and former Chaotic Wrestling ring announcer John Joseph Cena.
    "#
  }
}
