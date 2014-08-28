function LayoutManager() {};

LayoutManager.prototype.setLayout = function(layoutName) {
   this.layoutName = layoutName;
};

function getElemObj(rowName, ratio) {
   return {"row": rowName, "ratio": ratio};
};

LayoutManager.prototype.getLayout = function() { return this.layoutName; };

LayoutManager.prototype.setLayout = function(elemRatios) {
   this.elemRatios = elemRatios;
};

LayoutManager.prototype.applyLayout = function() {
   var totalHeight = window.innerHeight - 75; // 100 = combined navbar heights, 75 padding at top, 50px at bottom 
   var tenPercent = totalHeight / 10;
   var elemRatios = this.elemRatios;
   for (i = 0; i < elemRatios.length; i++) {
      document.getElementById(elemRatios[i].row).style.height = tenPercent * elemRatios[i].ratio + "px";
   }
};

var layoutManager
if (typeof layoutManager === 'undefined') 
   layoutManager = new LayoutManager();
$(window).resize(function () { layoutManager.applyLayout(); });


