import {Component, ElementRef, OnInit, ViewChild} from '@angular/core';
import {ChartOptions, ChartType, ChartDataSets} from 'chart.js';
import {Label, BaseChartDirective} from 'ng2-charts';
import {I18nService} from "core-app/modules/common/i18n/i18n.service";
import {DynamicBootstrapper} from "core-app/globals/dynamic-bootstrapper";
import 'chartjs-plugin-labels';
import {HalResourceService} from "core-app/modules/hal/services/hal-resource.service";
import {PathHelperService} from "core-app/modules/common/path-helper/path-helper.service";
import {DiagramHomescreenResource} from "core-app/modules/hal/resources/diagram-homescreen-resource";

export const homescreenPerformanceDiagramSelector = 'homescreen-performance-diagram';

@Component({
  selector: homescreenPerformanceDiagramSelector,
  templateUrl: './homescreen-performance-diagram.html'
})
export class HomescreenPerformanceDiagramComponent implements OnInit {
  public barChartOptions:ChartOptions = {
    responsive: true,
    maintainAspectRatio: false,
    scales: {
      xAxes: [{
        ticks: {
          display: false
        },
        gridLines: {
          display: false,
          drawBorder: false,
        }
      }],
      yAxes: [{
        ticks: {
          min:0,
          max:120,
          display: false
        },
        gridLines: {
          display: false,
          drawBorder: false,
        }
      }]
    },
    legend: {
      display: false,
      position: 'right',
      labels: {
        boxWidth: 15
      }
    },
    plugins: {
      labels: {
        render: 'value',
        fontSize: 14,
        fontStyle: 'bold',
        fontColor: '#000',
      }
    },
  };

  public barChartLabels:Label[] = ["1.", "2.", "3.", "4."];
  public barChartType:ChartType = 'bar';
  public barChartLegend = true;
  public barChartPlugins = [];
  public barChartData:ChartDataSets[] = [
    {data:[]}
  ];

  @ViewChild(BaseChartDirective) chart:BaseChartDirective;

  constructor(protected I18n:I18nService,
              readonly element:ElementRef,
              protected halResourceService:HalResourceService,
              protected pathHelper:PathHelperService) { }

  ngOnInit() {
    let barChartName = this.element.nativeElement.getAttribute('performance-id') || 0;
    /*this.halResourceService
      .get<DiagramHomescreenResource>(this.pathHelper.api.v3.diagrams.toString() + '/' + barChartName)
      .toPromise()
      .then((resource:DiagramHomescreenResource) => {
        this.barChartData[0].data = resource.data;
        this.barChartData[0].label = resource.label;
        });*/
    this.barChartData[0].data = [0, 0, 3, 0];
    this.barChartData[0].label = 'label';
    this.barChartData[0].backgroundColor = ['#00b050', '#ffc000', '#c00000', '#1f497d'];
  }

  public changeChartType() {
    this.chart.chartType = this.barChartType;
    this.chart.chart.update();
  }

  public refresh() {
    let barChartName = this.element.nativeElement.getAttribute('performance-id') || 0;
    if (barChartName % 2 === 0) {
      this.barChartData[0].data = [6, 0, 0, 0];
    } else {
      this.barChartData[0].data = [0, 0, 3, 0];
    }
    /*this.barChartData = JSON.parse(this.element.nativeElement.getAttribute('chart-data'));
    this.barChartData[0].backgroundColor = JSON.parse(this.element.nativeElement.getAttribute('chart-colors')) || ['#00b050', '#ffc000', '#c00000', '#1f497d'];
    this.chart.chart.update();*/
  }
}

DynamicBootstrapper.register({ selector: homescreenPerformanceDiagramSelector, cls: HomescreenPerformanceDiagramComponent });
