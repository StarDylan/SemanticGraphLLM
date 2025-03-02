from owlready2 import World, sync_reasoner_pellet, OwlReadyInconsistentOntologyError
from pathlib import Path

def check_consistency(ontology_rdf_file: Path, llm_generated_rdf_file: Path, verbose=False):
    # Create a new world to load both the ontology and KG
    my_world = World()

    # Load the ontology and KG
    my_world.get_ontology(str(ontology_rdf_file.absolute())).load()
    my_world.get_ontology(str(llm_generated_rdf_file.absolute())).load()


    if verbose:
        print(list(my_world.individuals()))
        print(list(my_world.classes()))

    try:
        sync_reasoner_pellet(my_world, debug=2)

    except OwlReadyInconsistentOntologyError as e:
        
        return False, str(e).split("This is the output of `pellet explain`: \n ")[1]

    return True, "KG is consistent with ontology"

if __name__ == "__main__":
    print(f"\n\n\n{check_consistency(Path('ontologies/pizza_ontology.owl'), Path('output.n3'))[1]}")
