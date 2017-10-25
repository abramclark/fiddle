// Question: Given a list/array with at least one positive integer, find the contiguous
// sub-array with the largest sum and output the sub-array in a list/array
// Example input: [-2, 1, -3, 4, -1, 2, 1, -5, 4]
// Example output: [4, -1, 2, 1]

// return index of first greatest element in list l
var max = (l)=>{ var i, a = -Infinity; l.forEach((x,j)=>{
    if(x>a){ i=j; a=x } }); return i }

var max_sublist = (l)=>{
  var sums = []; l.forEach((a,i)=>{
    if(a<=0) return
    var these_sums = l.slice(i).map((_,j)=>
      l.slice(i, i+j+1).reduce((x,y)=> x+y, 0, 0))
    var j = max(these_sums)
    sums.push([these_sums[j], i, i+j+1])
  })
  var best = max(sums.map(a=>a[0]))
  return l.slice(sums[best][1], sums[best][2])
}

var test = [-2, 1, -3, 4, -1, 2, 1, -5, 4]
JSON.stringify(max_sublist(test)) == JSON.stringify([4, -1, 2, 1])
