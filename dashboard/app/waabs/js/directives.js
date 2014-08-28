'use strict';

angular.module('myApp.directives').
  directive('corewaabDetails', function() {
    return {
      restrict: 'E',
      templateUrl: 'waabs/res/corewaab.html',
      scope: {
        vm: '=vm'
      },
      controller: function($scope, $interval, queryService) {
        console.log($scope.vm);

        // update data every period

        $scope.dataLoading = true;
        $scope.dataReceived = false;

        $scope.canPower = true;
        $scope.name = $scope.vm.name;

        // grab data, store in variable and update every period

        $scope.updateData = function(callback) {
          $scope.dataLoading = true;
          queryService.getData($scope.vm.id, "all", function(data, headers,status,config) {$scope.updateDataReceived(data,headers,status,config); callback();});
        };
 
        $scope.updateDataReceived = function(data, status, headers, config) {
          console.log(data);
          $scope.dataReceived = true;
          $scope.dataLoading = false;
          
          $scope.cpuData = data.cpu;
          $scope.ramData = data.ram;
          $scope.updateCpuGraph($scope.createCpuGraphData($scope.cpuData));
          $scope.updateRamGraph($scope.createRamGraphData($scope.ramData));

          $scope.powerstate = data.power.state;
          if ($scope.powerstate == "running" && $scope.canPower) {
            $scope.isOn = true;
            $scope.isOff = false;
          } else {
            $scope.isOff = true;
            $scope.isOn = false;
          }

          $scope.storage = data.storage.total + "GB";

          if (typeof data.ip.error == 'undefined') {
            $scope.ipv4 = data.ip.ipv4;
            $scope.ipv6 = data.ip.ipv6;
            $scope.hasIp = true;
          } else {
            $scope.hasIp = false;
          }
        };
/*
        $scope.updateCpu = function(data, status, headers, config) {
          $scope.updateCpuGraph($scope.createCpuGraphData(data));
        };
 
        $scope.updateRam = function(data, status, headers, config) {
          $scope.updateRamGraph($scope.createRamGraphData(data));
        };

        $scope.updatePower = function(data, status, headers, config) {
          $scope.powerstate = data.state;
        };

        $scope.updateStorage = function(data, status, headers, config) {
          $scope.storage = data.total + "GB";
        };
 
        $scope.updateIp = function(data, status, headers, config) {
          console.log(data);
          if (typeof data.error == 'undefined') {
            $scope.ipv4 = data.ipv4;
            $scope.ipv6 = data.ipv6;
            $scope.hasIp = true;
          } else {
            $scope.hasIp = false;
          }
        };

        $scope.getData = function() {
          queryService.getData($scope.id, "cpu", $scope.updateCpu);
          queryService.getData($scope.id, "ram", $scope.updateRam);
          queryService.getData($scope.id, "powerstate", $scope.updatePower);
          queryService.getData($scope.id, "ip", $scope.updateIp);
          queryService.getData($scope.id, "storage", $scope.updateStorage);
        }
*/

        $scope.powerStateChange = function(data, headers, status, config) {
          // refresh data
          $scope.updateData(function(){$scope.canPower = true;});
 
        };

        $scope.reboot = function() {
          $scope.canPower = false;
          queryService.sendCommand($scope.vm.id, "reboot", $scope.powerStateChange);
        };

        $scope.powerOn = function() {
          $scope.canPower = false;
          queryService.sendCommand($scope.vm.id, "start", $scope.powerStateChange);
        };
  
        $scope.powerOff = function() {
          $scope.canPower = false;
          queryService.sendCommand($scope.vm.id, "start", $scope.powerStateChange);
          queryService.sendCommand($scope.vm.id, "shutdown", $scope.powerStateChange);
        };

        $scope.updatePromise = $interval(function() { $scope.updateData(function(){}); }, 10000);

        $scope.$on('$destroy',function(){
          if ($scope.updatePromise)
            $interval.cancel($scope.updatePromise);   
        });

        $scope.updateData(function(){});

        $scope.createCpuGraphData = function(cpuLoadData) {
          var data = [{key:"CPU Load", values:[]}];
          if (cpuLoadData == null)
            return data;
          
          for (var i in cpuLoadData) {
            data[0].values.push({"label":"CPU"+i, "value":parseFloat(cpuLoadData[i].load)});
          } 
          return data;
        };

        $scope.createRamGraphData = function(data) {
          if (data == null)
            return [];
          var total = data.total;
          var free = data.free;
          var used = total - free;
          return [{"label": used + "MB Used", "value": used}, {"label": free + "MB Free", "value":free}];
        };

        $scope.updateCpuGraph = function(data) {
          nv.addGraph(function() {
            var chart = nv.models.discreteBarChart()
            .x(function(d) { return d.label })    //Specify the data accessors.
            .y(function(d) { return d.value })
            .staggerLabels(true)    //Too many bars and not enough room? Try staggering labels.
            .tooltips(false)        //Don't show tooltips
            .showValues(true)       //...instead, show the bar value right on top of each bar.
            .transitionDuration(350)
            ;

            d3.select($scope.cpuChart)
            .datum(data)
            .call(chart);

            nv.utils.windowResize(chart.update);

            return chart;
        });
       }

        $scope.updateRamGraph = function(data) {
           nv.addGraph(function() {
             var chart = nv.models.pieChart()
             .x(function(d) { return d.label })
             .y(function(d) { return d.value })
             .showLabels(true)
             .options({showLegend: false, tooltips: false });
             d3.select($scope.ramChart)
             .datum(data)
             .transition().duration(350)
             .call(chart);

             return chart;
          });
        };

      },
      link: function(scope, elem, attrs) {
        scope.cpuChart = elem.find("#cpu-chart")[0]
        scope.ramChart = elem.find("#ram-chart")[0]
        scope.storageChart = elem.find("#storage-chart")[0]
      }
    };
  });
