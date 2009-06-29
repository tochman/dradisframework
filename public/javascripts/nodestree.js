/*
 * nodestree.js
 * 4 / NOV / 2008
 *
 * This file contains the class definition of tthe dradis.NodesTree() object
 * used to represent the hierarchy of nodes stored in the database.
 */
Ext.ns('dradis');

dradis.NodesTree = Ext.extend(Ext.tree.TreePanel, {
  //props (overridable by caller)
  region: 'west',
  width: 300,
  autoScroll: true,
  border: false,
  split: true,
  useArrows:true,
  animate:true,

  initComponent: function(){
    // Called during component initialization
    var config ={
      //props (non-overridable)
      //------------------------------------------- standard TreePanel properties
      root: new Ext.tree.AsyncTreeNode({
        id: 'root-node',
        expanded: true
      }),
      rootVisible: false,
      enableDD:true,
      stateful:true,
      loader: new Ext.tree.TreeLoader({
        url: 'json/nodes',
        requestMethod: 'GET',
  	    createNode : function(attr){
    	    attr.text = Ext.util.Format.htmlEncode(attr.text);
  	    	return this.constructor.prototype.createNode.call(this, attr);
        }
      }),

      tbar: [
        {
          text: 'add branch', 
          iconCls:'icon-folder-add',
          scope: this,
          handler: function() {
            var root = this.getRootNode();
            var label = 'branch #' + (root.childNodes.length +1);
            var node = root.appendChild(new Ext.tree.TreeNode({ text: label }));
            addnode(node, function(new_id){ node.id = new_id; });
            this.editor.triggerEdit(node,false);
          }
        },    
        '-',
        {
          tooltip: 'Refresh the tree',
          iconCls:'x-tbar-loading',
          scope: this,
          handler: function(){ 
            this.loader.load( this.getRootNode() ); 
          }
        },
        {
          tooltip: 'Expand all',
          iconCls:'icon-expand-all',
          scope: this,
          handler: function(){ 
            this.expandAll(); 
          }
        },
        {
          tooltip: 'Collapse all',
          iconCls:'icon-collapse-all',
          scope: this,
          handler: function(){ 
            this.collapseAll(); 
          }
        },
        '-'
      ],
      //------------------------------------------- /standard TreePanel properties

      //------------------------------------------- custom NodesTree properties
      itemMenu: new Ext.menu.Menu({
        contextNode: null, // this will contain a reference to the right-clicked node
        items:[ 
        { 
          text: 'add child', 
          iconCls: 'add', 
          handler: function(){ 
            var parent = this.parentMenu.contextNode;
            var node = new Ext.tree.TreeNode({ text:'child node #' + (parent.childNodes.length+1) });
            parent.appendChild(node);
            addnode(node, function(new_id){ node.id = new_id; });
            node.getOwnerTree().editor.triggerEdit(node,false);
          }
        },
        { 
          text: 'delete node', 
          iconCls: 'del',
          handler: function(){
            var node = this.parentMenu.contextNode;
            if (node.parentNode) {
              delnode(node);
              node.remove();
            }     
          }
        },
        '-',
        { 
          text: 'expand node', 
          iconCls: 'icon-expand-all',
          handler: function(){
            this.parentMenu.contextNode.expand(true);
          }
        },
        { 
          text: 'collapse node', 
          iconCls: 'icon-collapse-all',
          handler: function(){
            this.parentMenu.contextNode.collapse(true);
          }
        }
        ]
      }),
      hiddenNodes: []
      //------------------------------------------- /custom NodesTree properties


    };

    // Config object has already been applied to 'this' so properties can 
    // be overriden here or new properties (e.g. items, tools, buttons) 
    // can be added, eg:
    Ext.apply(this, config);
    Ext.apply(this.initialConfig, config);

    // Before parent code

    // Call parent (required)
    dradis.NodesTree.superclass.initComponent.apply(this, arguments);

    // After parent code
    // e.g. install event handlers on rendered component
    // event definition for node click
    this.addEvents('nodeclick');

    // Inline editor for the node labels
    this.editor = new Ext.tree.TreeEditor(this, {}, {
      cancelOnEsc: true,
      completeOnEnter: true,
      ignoreNoChange: true,
      selectOnFocus: true
    });

    // Filter text field that will be added to the Tool bar and perform the
    // filtering in the tree of nodes
    this.filterField = new Ext.form.TextField({
      width: 130,
      emptyText:'Find a Node',
      tree: this,
      listeners:{
        render: function(f){
            f.el.on('keydown', function(ev){
              this.tree.filterNodes(this.getValue());
            }, this, {buffer: 350});
        }
      }
    });
    // add the text field to the toolbar
    this.getTopToolbar().push( this.filterField );

    // ==================================================== event handlers

    // Handle the context menu
    this.on('contextmenu', function(node, ev){
      // Register the context node with the menu so that a Menu Item's handler 
      // function can access it via its parentMenu property.
      node.select();
      node.expand();

      var contextMenu = this.itemMenu;
      contextMenu.contextNode = node;
      contextMenu.showAt(ev.getXY());
      ev.stopEvent();
    }, this);

    // Handle node click  
    this.on('click', function(node) {
      this.fireEvent('nodeclick', node.id);
    });

    // Handle label edits
    this.on('textchange', function(node, new_text, old_text){
        updatenode(node);
    });

    // Handle node drops (drag'n'drop)
    this.on('nodedrop', function(ev) {
      var point = ev.point;
      var node = ev.dropNode;
      var p = { id: node.id, label: node.text }
      if ( point == 'append') {
        p.parent_id = ev.target.id;
      } else {
        var parent = ev.target.parentNode;
        if (parent.id !== 'root-node') {
          p.parent_id = parent.id;
        }
      }
      p.authenticity_token = dradis.token;
      Ext.Ajax.request({
        url: '/json/node_update',
        params: p, 
        success: function(response, options) {
                    dradisstatus.setStatus({ 
                      text: 'Node repositioned',
                      clear: 5000
                  });
        },
        failure: function(response, options) {
                    dradisstatus.setStatus({
                      text: 'An error occured with the Ajax request',
                      iconCls: 'error',
                      clear: 5000
                    });
        }
      });

    });

    // ==================================================== /event handlers

  },

  // other methods/actions
  filterNodes: function(pattern){

    // un-hide the nodes that were filtered last time
    Ext.each(this.hiddenNodes, function(n){
      n.ui.show();
 		});

    if(!pattern){
      // no pattern -> nothing to be done
 			return;
 		}
    
    this.expandAll();
		
    var re = new RegExp('^.*' + Ext.escapeRe(pattern) + '.*', 'i');

    this.root.cascade( function(n){
      if (re.test(n.text)) {
        n.ui.show();
        n.bubble(function(){ this.ui.show(); });
      } else {
        n.ui.hide();
        this.hiddenNodes.push(n);
      }
    }, this);
  }

});


Ext.reg('nodestree', dradis.NodesTree);

