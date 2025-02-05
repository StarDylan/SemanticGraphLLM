from owlready2 import *
from pathlib import Path

def check_consistency(ontology_rdf_file: Path, llm_generated_rdf_file: Path):
    # Create a new world to load both the ontology and KG
    my_world = World()

    # Load the ontology and KG
    my_world.get_ontology(str(ontology_rdf_file.absolute())).load()
    my_world.get_ontology(str(llm_generated_rdf_file.absolute())).load()

    try:
        sync_reasoner_pellet(my_world, debug=2)

    except OwlReadyInconsistentOntologyError as e:
        
        return False, str(e).split("This is the output of `pellet explain`: \n ")[1]

    return True, "KG is consistent with ontology"

if __name__ == "__main__":
    print(f"\n\n\n{check_consistency(Path('ontologies/pizza.example.rdf'), Path('ontologies/pizza_invalid.rdf'))[1]}")