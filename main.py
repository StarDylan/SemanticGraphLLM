from dotenv import load_dotenv

load_dotenv()

from baml_client.types import FaultyPrompt
from pathlib import Path

from ner import named_entity_recognition
from verifier import check_consistency
from baml_utils import generate_triples, retry_triples
from graph_utils import load_ontology_into_graph, add_triples


source = "Pepperoni Pizza has pepperonni toppings and cheese and red sauce. The 'MegaPizza' contains Cheese and Pepperoni Pizza as toppings"
named_entities = named_entity_recognition(source)

ontology_text, graph = load_ontology_into_graph()
triples = generate_triples(source, named_entities, ontology_text)
add_triples(triples, graph)

while True:
    print(f"Loaded {len(graph)} triples from the ontology")
    print(graph.serialize(format="turtle"))

    # Write the XML to a file
    with open("output.xml", "w") as f:
        f.write(graph.serialize(format="xml"))
    # to_graph(g)
    success, message = check_consistency(
        Path("ontologies/pizza_ontology.owl"), Path("output.xml")
    )
    if success:
        break

    ontology_text, graph = load_ontology_into_graph()
    new_triples = retry_triples(triples, message, source, named_entities, ontology_text)
    if isinstance(new_triples, FaultyPrompt):
        print(new_triples.human_reason)
        raise SystemExit(1)

    add_triples(triples, graph)

print("Wrote output to output.xml")
