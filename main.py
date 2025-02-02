from baml_client.sync_client import b

from baml_client.types import Triple

# def example(raw_resume: str) -> list[Triple]: 

#   # BAML's internal parser guarantees ExtractResume

#   # to be always return a Resume type

#   response = b.ExtractTriples(raw_resume)

#   return response

# def example_stream(raw_resume: str) -> list[Triple]:

#   stream = b.stream.ExtractTriples(raw_resume)

# #   for msg in stream:

# #     print(msg) # This will be a PartialResume type

  

#   # This will be a Resume type

#   final = stream.get_final_response()

#   return final


# print(example_stream("I am a software engineer"))

from owlready2 import *
onto = get_ontology("file:///home/dylan/Documents/Dev/SemanticGraphLLM/urn_webprotege_ontology_3c57a96a-b1b5-4510-85a9-38e02ccbbc7d.owl")
onto.load()
for cls in onto.classes():
    class_iri = cls.iri
    labels = cls.label
    if labels:
        print(f"Class IRI: {class_iri}")
        print("Labels:")
        for label in labels:
            print(f"  - {label}")
        print()  # Add a newline for separation
    else:
        print(f"Class IRI: {class_iri} has no labels.\n")