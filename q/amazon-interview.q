max_sublist: {[l] starts: where l > 0;
  all_sums: 0+\' l each {y + til x - y}[count l] each starts;
  best_sums: first idesc max each all_sums;
  best_count: 1 + first idesc all_sums best_sums;
  l (starts best_sums) + til best_count }

4 -1 2 1 ~ max_sublist -2 1 -3 4 -1 2 1 -5 4

/ less readable as expression? 
max_sublist: {[l] l (starts best_sums) + til 1 + first idesc all_sums best_sums:
  first idesc max each all_sums: 0+\' l each {y + til x - y}[count l] each
  starts: where l > 0 }
