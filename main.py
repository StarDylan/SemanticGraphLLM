from dotenv import load_dotenv
load_dotenv()

from ner import named_entity_recognition


from baml_client.sync_client import b

from baml_client.types import Triple

def example(raw_resume: str) -> list[Triple]: 

  # BAML's internal parser guarantees ExtractResume

  # to be always return a Resume type

  response = b.ExtractTriples(raw_resume)

  return response

def example_stream(raw_resume: str) -> list[Triple]:

  stream = b.stream.ExtractTriples(raw_resume)

#   for msg in stream:

#     print(msg) # This will be a PartialResume type

  

  # This will be a Resume type

  final = stream.get_final_response()

  return final

with open("bee.txt", "r", errors="ignore") as f:
    text = f.read()
ents = named_entity_recognition(text)
print(ents)

print(example_stream("I am a software engineer"))
