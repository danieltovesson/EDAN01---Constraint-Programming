import org.jacop.constraints.*;
import org.jacop.core.*;
import org.jacop.search.*;

public class PhotoDistance {
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

		//test 1
		//int n = 9;
		//int n_prefs = 17;
		//int[][] prefs = {{1,3}, {1,5}, {1,8},
		//{2,5}, {2,9}, {3,4}, {3,5}, {4,1},
		//{4,5}, {5,6}, {5,1}, {6,1}, {6,9},
		//{7,3}, {7,8}, {8,9}, {8,7}};

		//test 2
		int n = 11;
		int n_prefs = 20;
		int[][] prefs = {{1,3}, {1,5}, {2,5},
		{2,8}, {2,9}, {3,4}, {3,5}, {4,1},
		{4,5}, {4,6}, {5,1}, {6,1}, {6,9},
		{7,3}, {7,5}, {8,9}, {8,7}, {8,10},
		{9, 11}, {10, 11}};


		//test 3
		//int n = 15;
		//int n_prefs = 20;
		//int[][] prefs = {{1,3}, {1,5}, {2,5},
		//		{2,8}, {2,9}, {3,4}, {3,5}, {4,1},
		//		{4,15}, {4,13}, {5,1}, {6,10}, {6,9},
		//		{7,3}, {7,5}, {8,9}, {8,7}, {8,14},
		//		{9, 13}, {10, 11}};

		// Decision variables
		IntVar[] seq = new IntVar[n];
		for (int i=0; i<n; i++) {
			seq[i] = new IntVar(store, "p"+i, 1, n);
		}
		IntVar[] fulfilled = new IntVar[n_prefs];
		for (int i=0; i<n_prefs; i++) {
			fulfilled[i] = new IntVar(store, "f"+i, 0, 1);
		}
		IntVar cost = new IntVar(store, "cost", n_prefs, n_prefs);
		IntVar minDistance = new IntVar(store, "minDistance", 0, n);
		// Constraints
		store.impose(new Alldifferent(seq));
		for (int i=0; i<n_prefs; i++) {
			int[] preference = prefs[i];
			IntVar first = seq[preference[0]-1];
			IntVar second = seq[preference[1]-1];
			IntVar distance = new IntVar(store, 0, n);
			store.impose(new Distance(first, second, distance));
			store.impose(new Reified(new XlteqY(distance, minDistance), fulfilled[i]));
		}
		store.impose(new Sum(fulfilled, cost));

		Search<IntVar> search = new DepthFirstSearch<IntVar>();
		SelectChoicePoint<IntVar> select = new SimpleSelect<IntVar>(
				seq,
				null,
				new IndomainMin<IntVar>());
		search.setSolutionListener(new PrintOutListener<IntVar>());

		boolean Result = search.labeling(store, select, minDistance);

		if (Result) {
			System.out.println("\n*** Yes");
			System.out.println("minimum distance : " + minDistance.value());
		} else {
			System.out.println("\n*** No");
		}
	}
}
