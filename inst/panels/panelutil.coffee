# A variety of utility functions used by the different panel functions

# determine rounding of axis labels
formatAxis = (d) ->
  d = d[1] - d[0]
  ndig = Math.floor( Math.log(d % 10) / Math.log(10) )
  ndig = 0 if ndig > 0
  ndig = Math.abs(ndig)
  d3.format(".#{ndig}f")

# unique values of array (ignore nulls)
unique = (x) ->
  output = {}
  output[v] = v for v in x when v
  output[v] for v of output

# Pull out a variable (column) from a two-dimensional array
pullVarAsArray = (data, variable) ->
  v = []
  for i of data
    v = v.concat data[i][variable]
  v
  
# calculate chromosome start/end + scales
chrscales = (data, width, chrGap) ->
  # start and end of chromosome positions
  chrStart = []
  chrEnd = []
  chrLength = []
  totalChrLength = 0
  for chr in data.chrnames
    rng = d3.extent(data.posByChr[chr])
    chrStart.push(rng[0])
    chrEnd.push(rng[1])
    L = rng[1] - rng[0]
    chrLength.push(L)
    totalChrLength += L

  # break up x axis into chromosomes by length, with gaps
  data.chrStart = []
  data.chrEnd = []
  cur = Math.round(chrGap/2)
  data.xscale = {}
  for chr,i in data.chrnames
    data.chrStart.push(cur)
    w = Math.round((width-chrGap*data.chrnames.length)/totalChrLength*chrLength[i])
    data.chrEnd.push(cur + w)
    cur = data.chrEnd[i] + chrGap
    # x-axis scales, by chromosome
    data.xscale[chr] = d3.scale.linear()
                         .domain([chrStart[i], chrEnd[i]])
                         .range([data.chrStart[i], data.chrEnd[i]])

  # return data with new stuff added
  data

# reorganize lod/pos in data by chromosome
reorgLodData = (data, lodvarname) ->
  data.posByChr = {}
  data.lodByChr = {}
  for chr,i in data.chrnames
    data.posByChr[chr] = []
    data.lodByChr[chr] = []
    for pos,j in data.pos
      data.posByChr[chr].push(pos) if data.chr[j] == chr
      data.lodByChr[chr].push(data[lodvarname][j]) if data.chr[j] == chr
  data.markers = []
  for marker,i in data.markernames
    if marker != ""
      data.markers.push({name:marker, chr:data.chr[i], pos:data.pos[i], lod:data[lodvarname][i]})
  data

# Select a set of categorical colors
# ngroup is positive integer
# palette = "dark" or "pastel"
selectGroupColors = (ngroup, palette) ->
  return [] if ngroup == 0

  if palette == "dark"
    return "slateblue" if ngroup == 1
    return ["MediumVioletRed", "slateblue"] if ngroup == 2
    return colorbrewer.Set1[ngroup] if ngroup <= 9
    return d3.scale.category20().range()[0...ngroup]
  else
    return d3.rgb(190, 190, 190) if ngroup == 1
    return ["lightpink", "lightblue"] if ngroup == 2
    return colorbrewer.Pastel1[ngroup] if ngroup <= 9
    # below is rough attempt to make _big_ pastel palette
    return ["#8fc7f4", "#fed7f8", "#ffbf8e", "#fffbb8",
            "#8ce08c", "#d8ffca", "#f68788", "#ffd8d6",
            "#d4a7fd", "#f5f0f5", "#cc968b", "#f4dcd4",
            "#f3b7f2", "#f7f6f2", "#bfbfbf", "#f7f7f7",
            "#fcfd82", "#fbfbcd", "#87feff", "#defaf5"][0...ngroup]