#!/usr/bin/env python3

from dotenv import load_dotenv

load_dotenv()

from pathlib import Path
import argparse
import sys


def generate_knowledge_graph(
    filename: str,
    ontology: str,
    outfile: str,
    verbose: bool = False,
) -> None:
    from ner import named_entity_recognition

    # FIXME: This sucks but is necessary
    import os

    if verbose:
        os.environ["BAML_LOG"] = "info"
    else:
        os.environ["BAML_LOG"] = "warn"

    from baml_utils import generate_triples, retry_triples
    from graph_utils import load_ontology_into_graph, add_triples, write_gephi_csv
    from verifier import check_consistency

    from baml_client.types import FaultyPrompt

    if filename == "-":
        source = sys.stdin.read()
    else:
        with open(filename, "r") as f:
            source = f.read()
    named_entities = named_entity_recognition(source)

    ontology_text, graph = load_ontology_into_graph(ontology)
    triples = generate_triples(source, named_entities, ontology_text)
    add_triples(triples, graph)

    for _ in range(5):
        if verbose:
            print(f"Loaded {len(graph)} triples from the ontology")
            print(graph.serialize(format="turtle"))

        with open(outfile, "w") as f:
            f.write(graph.serialize(format="xml"))
        write_gephi_csv(graph)
        success, message = check_consistency(Path(ontology), Path(outfile))
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
    else:
        print("Failed to generate valid xml after 5 tries, exiting.")
        raise SystemExit(1)

    print(f"Wrote output to {outfile}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        prog=sys.argv[0],
        description="Generates knowledge graphs based on the given text optionally conforming to the given ontology",
    )

    parser.add_argument("filename", help="file to read natural language from")
    parser.add_argument("-l", "--ontology", help="ontology to conform to")
    parser.add_argument("-v", "--verbose", action="store_true", help="verbose output")
    parser.add_argument("-o", "--output", default="output.xml", help="output filename")

    args = parser.parse_args()
    generate_knowledge_graph(
        args.filename, args.ontology, args.output, verbose=args.verbose
    )
