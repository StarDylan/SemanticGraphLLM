from dotenv import load_dotenv
load_dotenv()

from ner import named_entity_recognition

from baml_client.sync_client import b

from baml_client.types import Triple




def generate_triples(text: str, named_entities: list[str], ontology: str) -> list[Triple]:
    named_entities_str = ", ".join(named_entities)
    return b.ExtractTriples(text, named_entities_str, ontology)


with open("ontologies/pizza_ontology.owl") as f:
  ontology = f.read()

source = "Pepperoni Pizza has pepperonni toppings and cheese and red sauce"
named_entities = named_entity_recognition(source)

print(generate_triples(source, named_entities, ontology))

