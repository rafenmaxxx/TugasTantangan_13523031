require 'set'
require 'matrix'

# membaca file menjadi adjacency matrix
def readFile(path)
  file = File.open(path)
  lines = file.readlines.map(&:chomp)
  n = lines.size
  adjMatrix = Array.new(n) { Array.new(n, Float::INFINITY) }

  lines.each_with_index do |line, i|
    # jika terdapat simpul yang tidak bertetangga, file .txt akan berisi "-"
    # dan di-handle dengan mengubahnya menjadi Float::INFINITY
    val = line.split.map { |x| x == "-" ? Float::INFINITY : x.to_f } 
    adjMatrix[i] = val
  end

  [n, adjMatrix]
end

# fungsi untuk menampilkan matriks
def print_matrix(matrix)
  n = matrix.size

  # panjang maksimal dari semua elemen
  max_len = matrix.flatten.map { |val| format("%.1f", val).length }.max
  cell_width = [max_len, 3].max + 1 

  # header kolom
  print " " * (cell_width + 1) + "|"
  (1..n).each { |j| print " #{j.to_s.rjust(cell_width)} |" }
  puts

  # header baris
  (0...n).each do |i|
    print "#{(i + 1).to_s.rjust(cell_width)} |"

    # isi matriks
    (0...n).each do |j|
      val_str = format("%.1f", matrix[i][j])
      print " #{val_str.rjust(cell_width)} |"
    end
    puts
  
  end

end

# fungsi rekursif untuk menyelesaikan TSP
def TSP(i, s, matrix, memo, start, path_map)
  if s.empty?
    return matrix[i][start]
  end

  key = [i, s.sort]
  return memo[key] if memo.key?(key)

  min_cost = Float::INFINITY
  next_best = nil

  s.each do |j|
    s_next = s - [j]
    cost = matrix[i][j] + TSP(j, s_next, matrix, memo, start, path_map)
    if cost < min_cost
      min_cost = cost
      next_best = j
    end
  end

  memo[key] = min_cost
  path_map[key] = next_best
  return min_cost
end

# fungsi untuk mendapatkan rute dari hasil TSP
def getPath(i, s, path_map, start)
  path = [i]

  while !s.empty?
    key = [i, s.sort]
    next_city = path_map[key]
    break unless next_city

    path << next_city
    s = s - [next_city]
    i = next_city
  end

  path << start
  path
end

puts "\n\\(•ᴗ•\\) Selamat datang di program penyelesaian TSP (Travelling Salesperson Problem)! (/•ᴗ•)/"
puts "Masukkan nama file persoalan (ex: tes.txt):"
fileName = gets.chomp
file = File.join("tes", fileName)
n, matrix = readFile(file)

puts "\nMatriks di dalam file #{fileName}:"
print_matrix(matrix)

startIdx = -1
while startIdx < 0 || startIdx >= n
  puts "\nMasukkan simpul awal (1 - #{n}):"
  startIdx = gets.to_i - 1
  if startIdx < 0 || startIdx >= n
    puts "Simpul awal tidak valid. Silakan coba lagi."
  end
end

# memo menyimpan memoization sebagai dasar dynamic programming
memo = {}

# path_map menyimpan rute yang diambil untuk setiap state
path_map = {}

# Set berisi semua simpul yang belum dikunjungi
s = Set.new((0...n).to_a - [startIdx])

minCost = TSP(startIdx, s, matrix, memo, startIdx, path_map)

# # debug memo:
# puts "memo: "
# memo.each do |key, value|
#   puts "#{key.inspect} => #{value}"
# end

# # debug path_map
# puts "path_map: "
# path_map.each do |key, value|
#   puts "#{key.inspect} => #{value}"
# end

path = getPath(startIdx, s, path_map, startIdx)
puts "\nRute TSP untuk persoalan #{fileName} dari simpul #{startIdx + 1} adalah [ #{path.map { |x| x + 1 }.join(' - ')} ] dengan total biaya #{minCost}"
puts "Rincian perjalanan:"
for i in 0...(path.size - 1)
  puts "#{i+1}) #{path[i] + 1} → #{path[i + 1] + 1}: #{matrix[path[i]][path[i + 1]]}"
end
puts