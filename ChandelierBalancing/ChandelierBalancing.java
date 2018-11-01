import org.jacop.constraints.*;
import org.jacop.core.*;
import org.jacop.search.*;

public class ChandelierBalancing {
  public static void main(String[] args) {
    long T1, T2, T;
    T1 = System.currentTimeMillis();

    send();

    T2 = System.currentTimeMillis();
    T = T2 - T1;
    System.out.println("\n\t*** Execution time = " + T + " ms");
  }

  static void send() {
    Store store = new Store();

    // Define finite domain variables
    IntVar a = new IntVar(store, "a", 1, 9);
    IntVar b = new IntVar(store, "b", 1, 9);
    IntVar c = new IntVar(store, "c", 1, 9);
    IntVar d = new IntVar(store, "d", 1, 9);
    IntVar e = new IntVar(store, "e", 1, 9);
    IntVar f = new IntVar(store, "f", 1, 9);
    IntVar g = new IntVar(store, "g", 1, 9);
    IntVar h = new IntVar(store, "h", 1, 9);
    IntVar i = new IntVar(store, "i", 1, 9);
    IntVar[] weights = { a, b, c, d, e, f, g, h, i };

    // Define constraints
    store.impose(new Alldiff(weights));
    store.impose(new XeqY(2*a, 1*b+2*c));
    store.impose(new XeqY(2*d+1*e, 1*f));
    store.impose(new XeqY(2*g+1*h, 3*i));
    store.impose(new XeqY(3*(a+b+c), 2*(d+e+f)+3*(g+h+i)));

    System.out.println("Number of variables: "+ store.size() +
                        "\nNumber of constraints: " + store.numberConstraints());

    Search<IntVar> search = new DepthFirstSearch<IntVar>(); SelectChoicePoint<IntVar> select = new SimpleSelect<IntVar>(weights,
      null,
      new IndomainMin<IntVar>());
    search.setSolutionListener(new PrintOutListener<IntVar>());

    boolean Result = search.labeling(store, select);

    if (Result) {
      System.out.println("\n*** Yes");
      System.out.println("Solution : "+ java.util.Arrays.asList(weights));
    } else {
      System.out.println("\n*** No");
    }
  }
}
