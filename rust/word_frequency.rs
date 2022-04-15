use std::collections::HashMap;
use std::io::{stdin, BufRead};

fn main() {
    let mut counts: HashMap<String, u32>= HashMap::new();
    stdin().lock().lines().for_each(|s| {
      *counts.entry(s.unwrap()).or_insert(0) += 1;
    });    

    let mut word_counts: Vec<(&String, &u32)> = counts.iter().collect();
    word_counts.sort_by_key(|r| r.1);

    word_counts.iter().for_each(|(word, count)|
      println!("{}: {}", word, count)
    )
}
