/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

package seakers.architecture.util;

import java.util.Objects;

/**
 * This class represents an ordered pair which views {a,b} as inequivalent to
 * {b,a}, where a and b are sets themselves.
 * @author nozomihitomi
 */
public class OrderedPair<T> {
    
    private final T a;
    private final T b;

    public OrderedPair(T a, T b) {
        this.a = a;
        this.b = b;
    }
    
    /**
     * Gets the first value in the index. Returns a in pair (a,b)
     * @return 
     */
    public T getFirst(){
        return a;
    }
    
    /**
     * Gets the second value in the index. Returns b in pair (a,b)
     * @return 
     */
    public T getSecond(){
        return b;
    }

    @Override
    public int hashCode() {
        int hash = 5;
        hash = 23 * hash + Objects.hashCode(this.a);
        hash = 23 * hash + Objects.hashCode(this.b);
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
        final OrderedPair<?> other = (OrderedPair<?>) obj;
        if (!Objects.equals(this.a, other.a)) {
            return false;
        }
        if (!Objects.equals(this.b, other.b)) {
            return false;
        }
        return true;
    }

    
    
    
    
}
