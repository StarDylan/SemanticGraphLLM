from dotenv import load_dotenv
load_dotenv()

from ner import named_entity_recognition

from baml_client.sync_client import b

from baml_client.types import Triple
from verifier import check_consistency
from pathlib import Path

import rdflib
import pandas as pd

def generate_triples(text: str, named_entities: list[str], ontology_text: str) -> list[Triple]:
    named_entities_str = ", ".join(named_entities)
    return b.ExtractTriples(text, named_entities_str, ontology_text)


def add_triples(triples: list[Triple], graph: rdflib.Graph) -> None:
  for triple in triples:
    # Resolve IRIs
    subject = rdflib.URIRef(triple.subjectIRI)
    predicate = rdflib.URIRef(triple.predicateIRI)
    obj = rdflib.URIRef(triple.objectIRI)

    graph.add((subject, predicate, obj))

def get_label(node):
    if isinstance(node,rdflib.URIRef):
        uri = str(node)
        if '#' in uri:
            return uri.split('#')[-1]
        else:
            parts = uri.split('/')
            return parts[-1] if parts[-1] else parts[-2]
    elif isinstance(node, rdflib.Literal):
        return str(node)
    elif isinstance(node, rdflib.BNode):
        return f"BlankNode_{node}"
    else:
        return str(node)

def to_graph(graph: rdflib.Graph):
  nodes = set()
  edges = []

  for s, p, o in graph:
      # Process subject
      s_id = str(s)
      s_label = get_label(s)
      nodes.add((s_id, s_label))

      # Process object
      o_id = str(o)
      o_label = get_label(o)
      nodes.add((o_id, o_label))

      # Process predicate for edge label
      p_label = get_label(p)
      edges.append((s_id, o_id, p_label))

  # Write nodes to CSV
  nodes_df = pd.DataFrame(list(nodes), columns=['Id', 'Label'])
  nodes_df.to_csv("nodes.csv", index=False)

  # Write edges to CSV
  edges_df = pd.DataFrame(edges, columns=['Source', 'Target', 'Label'])
  edges_df.to_csv("edges.csv", index=False)


g = rdflib.Graph()
# Get text
file = Path("ontologies/pizza_ontology.owl")
with open(file, "r") as f:
  ontology_text = f.read()


g.parse(data=ontology_text, format="xml")

print(f"Loaded {len(g)} triples from the ontology")
print(g.serialize(format="turtle"))

source = "Pepperoni Pizza has pepperonni toppings and cheese and red sauce. The 'MegaPizza' contains Cheese Pizza and Pepperoni Pizza as toppings"
named_entities = named_entity_recognition(source)

triples = generate_triples(source, named_entities, ontology_text)
add_triples(triples, g)

# Write the XML to a file
with open("output.xml", "w") as f:
  f.write(g.serialize(format="xml"))


to_graph(g)



result = check_consistency(Path("ontologies/pizza_ontology.owl"), Path("output.xml"))
print(result)