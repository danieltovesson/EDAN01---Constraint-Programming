import org.jacop.constraints.*;
import org.jacop.core.*;
import org.jacop.search.*;

public class PhotoCost {
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

    int n = 9;
    int n_prefs = 17;
    int[][] prefs = {{1,3}, {1,5}, {1,8},
    {2,5}, {2,9}, {3,4}, {3,5}, {4,1},
    {4,5}, {5,6}, {5,1}, {6,1}, {6,9},
    {7,3}, {7,8}, {8,9}, {8,7}};

    // Decision variables
    IntVar[] seq = new IntVar[n];
    IntVar[] indexes = new IntVar[n];
    for (int i=0; i<n; i++) {
      seq[i] = new IntVar(store, "p"+i, 1, n);
      indexes[i] = new IntVar(store, "i"+i, 1, n);
    }
    IntVar[] fulfilled = new IntVar[n_prefs];
    for (int i=0; i<n_prefs; i++) {
      fulfilled[i] = new IntVar(store, "f"+i, 0, 1);
    }
    IntVar cost = new IntVar(store, "cost", 0, n_prefs);

    // Constraints
    store.impose(new Alldifferent(seq));

    Search<IntVar> search = new DepthFirstSearch<IntVar>();
    SelectChoicePoint<IntVar> select = new SimpleSelect<IntVar>(
      seq,
      null,
      new IndomainMin<IntVar>());
    search.setSolutionListener(new PrintOutListener<IntVar>());

    boolean Result = search.labeling(store, select, cost);

    if (Result) {
      System.out.println("\n*** Yes");
      System.out.println("Solution : "+ java.util.Arrays.asList(cost));
    } else {
      System.out.println("\n*** No");
    }
  }
}
