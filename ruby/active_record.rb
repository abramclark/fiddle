def bulk_query(
  collection, for_record, window:50000, delay:0,
  skip:0, max_to_min:true, limit:false
)
  min = collection.minimum('id')
  max = collection.maximum('id')
  win_min =  max_to_min ? max - window - skip : min - skip
  win_max = !max_to_min ? min + window + skip : max + skip
  count = 0
    
  while (
    (max_to_min ? win_min >= min : win_max <= max) and
    (limit ? count < limit : true)
  )
    batch = collection.where('id >= ? and id < ?', win_min, win_max)
    batch.each do |record| for_record.call record end
    puts "#{win_min} .. #{win_max} (+#{count})"
    win_min = max_to_min ? win_min - window : win_min + window
    win_max = max_to_min ? win_max - window : win_max + window
    count += window
    sleep delay
  end
end
