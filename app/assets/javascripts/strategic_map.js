// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
// = require network

var nodes = new vis.DataSet();

// create an array with edges
var edges = new vis.DataSet();

// create a network
var container = document.getElementById('mynetwork');

// provide the data in the vis format
var data = {
  nodes: nodes,
  edges: edges
};
var options = {
  nodes: {
    borderWidth: 1,
    borderWidthSelected: 2,
    shape: 'box',
    physics: false,
    fixed: false,
    labelHighlightBold: false,
    widthConstraint:{
      minimum: 10,
      maximum: 200
    },
    heightConstraint:{
      minimum: 20,
      valign: 'middle'
    }
  },
  groups: {
    useDefaultGroups: false,
    National: {},
    Federal: {},
  },
  edges: {
    arrows: {
      to: {
        enabled: true,
        type: 'arrow'
      }
    },
    color:{
      inherit: 'both'
    },
    physics: true
  },
  layout: {
    hierarchical: {
      enabled: true,
      direction: 'UD',
      sortMethod: 'directed',
      parentCentralization: true,
      edgeMinimization: true,
      treeSpacing: 200,
      nodeSpacing: 250,
      levelSeparation: 150,
      blockShifting: true
    }
  },
  interaction:{
    dragNodes: true,
    dragView: true,
    hoverConnectedEdges: true,
    selectable: true,
    selectConnectedEdges: true,
    zoomView:true,
    hover: true
  },
  autoResize: true,
  height: '100%',
  width: '100%',
  locale: 'ru'
};


// initialize your network!
var network = new vis.Network(container, data, options);

function cutString(string, maxlength) {
  var temp = string.split(' ');
  if (temp.length > maxlength) {
  string = string.split(' ', maxlength).join(' ') + '...';
  }
  return string;
}
function getProjects(){
  jQuery.ajax({
    type: 'GET',
    url:'strategic_map/get_list',
    data: {national_id: jQuery(document).find('#choose_project_for_map')[0].value},
    async: true,
    success: function (json){
      nodes.clear();
      edges.clear();
      var groups = new Array();
      json.forEach(function (element) {

        nodes.add({
          id: element[2],
          title: element[0],
          group: element[3],
          label: element[0]
          // color:
        });
        if ( element[1] && element[2] ) {
          edges.add({
            from: element[1],
            to: element[2]
          });
        }
      });
      network = new vis.Network(container, data, options);
      network.fit();
    }
  });
}
var loadData=function(){
  jQuery('button.button-load-data').click(function()
  {
    getProjects();
  });
};

jQuery(document).ready(loadData());
