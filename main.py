import dotenv
dotenv.load_dotenv()
from baml_client.sync_client import b

from baml_client.types import Triple
from verifier import check_consistency
from pathlib import Path

import rdflib
import pandas as pd

def generate_triples(text: str, ontology: str) -> list[Triple]:
  # BAML's internal parser guarantees ExtractResume

  # to be always return a Resume type

  response = b.ExtractTriples(text, ontology)

  return response


def add_triples(triples: list[Triple], graph: rdflib.Graph) -> None:
  for triple in triples:
    # Resolve IRIs
    subject = rdflib.URIRef(triple.subjectIRI)
    predicate = rdflib.URIRef(triple.predicateIRI)
    obj = rdflib.URIRef(triple.objectIRI)

    # Double check each iri already exists
    if not graph.value(subject):
      print(f"WARNING: {subject} does not exist in the ontology")

    if not graph.value(obj):
      print(f"WARNING: {obj} does not exist in the ontology")

    if not graph.value(predicate):
      print(f"WARNING: {predicate} does not exist in the ontology")


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
  text = f.read()


g.parse(data=text, format="xml")

print(f"Loaded {len(g)} triples from the ontology")
print(g.serialize(format="turtle"))

triples = generate_triples("Pepperoni pizza contains Cheese Pizza", text)
add_triples(triples, g)

# Write the XML to a file
with open("output.xml", "w") as f:
  f.write(g.serialize(format="xml"))


to_graph(g)



result = check_consistency(Path("ontologies/pizza_ontology.owl"), Path("output.xml"))
print(result)