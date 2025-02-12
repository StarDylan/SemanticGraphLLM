import spacy

nlp = spacy.load("en_core_web_lg")

def named_entity_recognition(text: str) -> list[str]:
    doc = nlp(text)
    return [ent.text for ent in doc.ents] + [tok.text for tok in doc if tok.pos_ == "NOUN" or tok.pos_ == "PROPN"]
