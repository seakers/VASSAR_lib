package rbsa.eoss;

import java.io.*;
import java.util.Arrays;


public class Interval implements Serializable {
	private double min;
	private double max;

	public Interval(String type, double a, double b)  {
		if (type.equals("interval")) {
			this.min = a;
			this.max = b;
		}
		else if (type.equals("delta")) {
			this.min = a * (1 - b/100);
			this.max = a * (1 + b/100);
		}
	}

	// Manipulating fuzzy values
	public Interval add(Interval other) {
		// assume same unit and parameter
		double new_min = this.min + other.min;
		double new_max = this.max + other.max;
		return new Interval("interval", new_min, new_max);
	}

	public Interval minus(Interval other) {
		double new_min = this.min - other.max;
		double new_max = this.max - other.min;
		return new Interval("interval", new_min, new_max);
	}

	public Interval prod(Interval other) {
		double[] arr = {this.min*other.min, this.min*other.max, this.max*other.min, this.max*other.max};
		Arrays.sort(arr);
		double new_max = arr[arr.length-1];
		double new_min = arr[0];
		return new Interval("interval", new_min, new_max);
	}

	public Interval times(double scal) {
		double new_min = scal*this.min;
		double new_max = scal*this.max ;
		return new Interval("interval", new_min, new_max);
	}

	public Interval exp(double scal) {
		double a = Math.pow(min, scal);
		double b = Math.pow(max, scal);
		double lo = Math.min(a,b);
		double hi = Math.max(a,b);
		return new Interval("interval", lo, hi);
	}

	public boolean intersects(Interval b) {
		Interval a = this;
		if (b.min <= a.max && b.min >= a.min) {
			return true;
		}
		if (a.min <= b.max && a.min >= b.min) {
			return true;
		}
		return false;
	}

	public String toString() {
		return ("[ " + this.getMin() + " , " + this.getMax() + " ]");
	}

	// Getters and setters
	public double getMean() {
		return (this.min + this.max)/2;
	}

	public double getMin() {
		return this.min;
	}

	public double getMax() {
		return this.max;
	}
}
