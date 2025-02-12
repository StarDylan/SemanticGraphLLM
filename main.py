from dotenv import load_dotenv
load_dotenv()

from ner import named_entity_recognition

from baml_client.sync_client import b

from baml_client.types import Triple




def generate_triples(text: str, ontology: str) -> list[Triple]:
  # BAML's internal parser guarantees ExtractResume

  # to be always return a Resume type

  response = b.ExtractTriples(text, ontology)

  return response


with open("ontologies/pizza_ontology.owl") as f:
  ontology = f.read()

print(generate_triples("Pepperoni Pizza has pepperonni toppings and cheese and red sauce", ontology))

with open("data/bee.txt", "r", errors="ignore") as f:
    text = f.read()
ents = named_entity_recognition(text)
print(ents)
