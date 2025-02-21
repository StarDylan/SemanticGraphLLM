#!/usr/bin/env python3

from dotenv import load_dotenv

load_dotenv()

# FIXME: This sucks but is necessary
import os
os.environ["BAML_LOG"] = "warn"

from ner import named_entity_recognition
from verifier import check_consistency
from baml_utils import generate_triples, retry_triples
from graph_utils import load_ontology_into_graph, add_triples

from baml_client.types import FaultyPrompt
from pathlib import Path
import argparse
import sys


def generate_knowledge_graph(filename: str, ontology: str, verbose: bool = False) -> None:
    if filename == '-':
        source = sys.stdin.read()
    else:
        with open(filename, "r") as f:
            source = f.read()
    named_entities = named_entity_recognition(source)

    ontology_text, graph = load_ontology_into_graph(ontology)
    triples = generate_triples(source, named_entities, ontology_text)
    add_triples(triples, graph)

    while True:
        if verbose:
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

        ontology_text, graph = load_ontology_into_graph(ontology)
        new_triples = retry_triples(
            triples, message, source, named_entities, ontology_text
        )
        if isinstance(new_triples, FaultyPrompt):
            print(new_triples.human_reason)
            raise SystemExit(1)

        add_triples(triples, graph)

    print("Wrote output to output.xml")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        prog=sys.argv[0],
        description="Generates knowledge graphs based on the given text optionally conforming to the given ontology",
    )

    parser.add_argument("filename", help="file to read natural language from")
    parser.add_argument("-l", "--ontology", help="ontology to conform to")
    parser.add_argument("-v", "--verbose", action="store_true", help="verbose output")

    args = parser.parse_args()
    generate_knowledge_graph(args.filename, args.ontology, args.verbose)
