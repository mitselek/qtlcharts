// Generated by CoffeeScript 1.7.1
d3.json("data.json", function(data) {
  var mychart;
  mychart = mapchart();
  return d3.select("div#chart").datum(data).call(mychart);
});
