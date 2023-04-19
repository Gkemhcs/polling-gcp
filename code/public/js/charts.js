google.charts.load('current');   // Don't need to specify chart libraries!
google.charts.setOnLoadCallback(drawVisualization);


function drawVisualization() {
 var results=document.getElementById("results").innerHTML
  
const list=results.split(",")
 
const result=[]
for(i=0;i<list.length;i++){
    result[i]=Number(list[i])
}
  

result.unshift(' ')
 
  var wrapper = new google.visualization.ChartWrapper({
    chartType: 'BarChart',
    dataTable: [["","whatsapp","facebook","twitter","instagram"],
            result],
    options: {'title': 'POLLING-RESULTS'},
    containerId: 'pie_div'
  });
  wrapper.draw();
}
