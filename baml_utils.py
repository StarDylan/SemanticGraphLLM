import json

from baml_client.types import FaultyPrompt, Triple
from baml_client.sync_client import b

def triple_to_dict(triple: Triple) -> dict[str, str]:
    return {
        "subjectIRI": triple.subjectIRI,
        "predicateIRI": triple.predicateIRI,
        "objectIRI": triple.objectIRI,
    }

def generate_triples(
    text: str, named_entities: list[str], ontology_text: str
) -> list[Triple]:
    named_entities_str = ", ".join(named_entities)

    result = b.ExtractTriples(text, named_entities_str, ontology_text, [])
    last = result[-1]
    if "[[DONE]]" in last.subjectIRI.upper():
        return result[:-1]
    else:
        while True:
            print("Last triple wasn't DONE, extending the triple set...")
            next_result = b.ExtractTriples(text, named_entities_str, ontology_text, result)
            result.extend(next_result)
            last = result[-1]
            if "[[DONE]]" in last.subjectIRI.upper():
                return result[:-1]


def retry_triples(
    old_triples: list[Triple],
    reasoner_failed_reason: str,
    text: str,
    named_entities: list[str],
    ontology_text: str,
) -> list[Triple] | FaultyPrompt:
    triples_str = json.dumps(
        [triple_to_dict(triple) for triple in old_triples], indent=2
    )
    named_entities_str = ", ".join(named_entities)
    return b.RetryTriples(
        triples_str,
        reasoner_failed_reason,
        text,
        named_entities_str,
        ontology_text,
    )
