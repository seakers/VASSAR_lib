/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package seakers.architecture.pattern;

/**
 *
 * There are 6 patterns of architectural decisions: COMBINING, downselecting,
 assigning, partitioning, permuting, connecting
 *
 * @author nozomihitomi
 */
public enum DecisionPattern {

    /**
     * There is a group of decisions where each decision has its own discrete
     * set of options, and an architecture fragment is defined by choosing
     * exactly one option from each decision.
     */
    COMBINING,
    /**
     * There is a set of candidate entities and an architecture fragment is
     * defined by choosing a subset of it.
     */
    DOWNSELECTING,
    /**
     * There are two different sets of entities, and an architecture fragment is
     * defined by assigning each entity from one set to any subset of entities
     * from the other set.
     */
    ASSINGING,
    /**
     * There is a set of entities and an architecture fragment is defined by a
     * partition of the set into subsets that are mutually exclusive and
     * collectively exhaustive.
     */
    PARTITIONING,
    /**
     * There is a set of entities and an architecture fragment is defined by an
     * ordering or permutation of the set.
     */
    PERMUTING,
    /**
     * There is a set of entities that can be seen as the nodes in a graph and
     * an architecture fragment is defined by the set of edges in the graph,
     * i.e. the way of connecting those nodes.
     */
    CONNECTING
}
