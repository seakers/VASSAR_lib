
import rbsa.eoss.*
import rbsa.eoss.local.*

RM = ResultManager.getInstance;
res_col = RM.loadResultCollectionFromFile([char(params.path_save_results) '\\2014-02-05_09-39-17_test.rs']);
results = res_col.getResults;
res = results.get(0);
explain_results2(res,AE,params);