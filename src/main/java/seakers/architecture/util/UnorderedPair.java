/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package seakers.architecture.util;

import java.util.Objects;

/**
 * This class represents an unordered pair which views {a,b} as equivalent to
 * {b,a}, where a and b are sets themselves.
 *
 * @author nozomihitomi
 * @param <T>
 */
public class UnorderedPair<T> extends OrderedPair<T> {

    public UnorderedPair(T a, T b) {
        super(a, b);
    }
    @Override
    public int hashCode() {
        int hash = 5;
        hash = 23 * hash + Objects.hashCode(this.getFirst()) + Objects.hashCode(this.getSecond());
        return hash;
    }

    @Override
    public boolean equals(Object obj) {
        if (obj == null) {
            return false;
        }
        if (getClass() != obj.getClass()) {
            return false;
        }
        final UnorderedPair<?> other = (UnorderedPair<?>) obj;
        if (Objects.equals(this.getFirst(), other.getFirst())&&Objects.equals(this.getSecond(), other.getSecond())||
            Objects.equals(this.getFirst(), other.getSecond())&&Objects.equals(this.getFirst(), other.getSecond())   ) {
            return true;
        }
        return false;
    }
    
    
}
