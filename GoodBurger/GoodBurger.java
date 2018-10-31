import org.jacop.constraints.*;
import org.jacop.core.*;
import org.jacop.search.*;

public class GoodBurger {
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
    IntVar beefPatty = new IntVar(store, "Beef Patty", 1, 5);
    IntVar bun = new IntVar(store, "Bun", 1, 5);
    IntVar cheese = new IntVar(store, "Cheese", 1, 5);
    IntVar onions = new IntVar(store, "Onions", 1, 5);
    IntVar pickles = new IntVar(store, "Pickles", 1, 5);
    IntVar lettuce = new IntVar(store, "Lettuce", 1, 5);
    IntVar ketchup = new IntVar(store, "Ketchup", 1, 5);
    IntVar tomato = new IntVar(store, "Tomato", 1, 5);
    IntVar[] ingredients = { beefPatty, bun, cheese, onions, pickles, lettuce, ketchup, tomato };
    IntVar combinedPrice = new IntVar(store, "Combined Price", -1000, 1000);
    int[] sodium = { 50, 330, 310, 1, 260, 3, 160, 3 };
    int[] fat = { 17, 9, 6, 2, 0, 0, 0, 0 };
    int[] calories = { 220, 260, 70, 10, 5, 4, 20, 9 };
    int[] price = { -25, -15, -10, -9, -3, -4, -2, -4 };

    // Define constraints
    store.impose(new XeqY(ketchup, lettuce));
    store.impose(new XeqY(pickles, tomato));
    store.impose(new LinearInt(ingredients, sodium, "<", 3000));
    store.impose(new LinearInt(ingredients, fat, "<", 150));
    store.impose(new LinearInt(ingredients, calories, "<", 3000));
    store.impose(new LinearInt(ingredients, price, "==", combinedPrice));

    System.out.println("Number of variables: "+ store.size() +
                        "\nNumber of constraints: " + store.numberConstraints());

    Search<IntVar> search = new DepthFirstSearch<IntVar>(); SelectChoicePoint<IntVar> select = new SimpleSelect<IntVar>(ingredients,
      null,
      new IndomainMin<IntVar>());
    search.setSolutionListener(new PrintOutListener<IntVar>());

    boolean Result = search.labeling(store, select, combinedPrice);

    if (Result) {
      System.out.println("\n*** Yes");
      System.out.println("Solution : "+ java.util.Arrays.asList(ingredients));
    } else {
      System.out.println("\n*** No");
    }
  }
}
