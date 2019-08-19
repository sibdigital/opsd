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
export class HomescreenPerformanceDiagramComponent {
  public zagolovok:string;
  public barChartOptions:ChartOptions = {
    responsive: true,
    maintainAspectRatio: false,
    scales: {
      xAxes: [{
        ticks: {
          display: false,
        },
        gridLines: {
          display: false,
          drawBorder: false,
        }
      }],
      yAxes: [{
        ticks: {
          beginAtZero: true,
          display: false
        },
        gridLines: {
          display: false,
          drawBorder: false,
        }
      }]
    },
    legend: {
      display: true,
      position: 'bottom',
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

  public barChartLabels:Label[] = ['Показатель'];
  public barChartType:ChartType = 'bar';
  public barChartLegend = true;
  public barChartPlugins = [];
  public barChartData:ChartDataSets[] = [
    {data:[0], label: "1.", backgroundColor: '#00b050', hoverBackgroundColor: '#00b050'},
    {data:[0], label: "2.", backgroundColor: '#ffc000', hoverBackgroundColor: '#ffc000'},
    {data:[0], label: "3.", backgroundColor: '#c00000', hoverBackgroundColor: '#c00000'},
    {data:[0], label: "4.", backgroundColor: '#1f497d', hoverBackgroundColor: '#1f497d'}
  ];

  @ViewChild(BaseChartDirective) chart:BaseChartDirective;

  constructor(protected I18n:I18nService,
              readonly element:ElementRef,
              protected halResourceService:HalResourceService,
              protected pathHelper:PathHelperService) { }

  public refresh() {
    let barChartName = this.element.nativeElement.getAttribute('performance-id') || 0;
    this.halResourceService
      .get<DiagramHomescreenResource>(this.pathHelper.api.v3.diagrams.toString() + '/head_performance', {performance: barChartName})
      .toPromise()
      .then((resource:DiagramHomescreenResource) => {
        let maxim:number | undefined = _.max(resource.data);
        if (maxim && this.chart.options.scales && this.chart.options.scales.yAxes) {
          let maxValue = Number((maxim * 2).toFixed(0));
          this.chart.options.scales.yAxes[0] = {
            ticks: {
              max: maxValue,
              beginAtZero: true,
              display: false
            },
            gridLines: {
              display: true,
              drawBorder: false,
            }
          };
          this.chart.chart.update();
        }
        this.barChartData = [];
        this.barChartData.push({data:[resource.data[0]], label: "1.", backgroundColor: '#00b050', hoverBackgroundColor: '#00b050'});
        this.barChartData.push({data:[resource.data[1]], label: "2.", backgroundColor: '#ffc000', hoverBackgroundColor: '#ffc000'});
        this.barChartData.push({data:[resource.data[2]], label: "3.", backgroundColor: '#c00000', hoverBackgroundColor: '#c00000'});
        this.barChartData.push({data:[resource.data[3]], label: "4.", backgroundColor: '#1f497d', hoverBackgroundColor: '#1f497d'});
        this.zagolovok = resource.label;
      });
    /*this.barChartData = JSON.parse(this.element.nativeElement.getAttribute('chart-data'));
    this.barChartData[0].backgroundColor = JSON.parse(this.element.nativeElement.getAttribute('chart-colors')) || ['#00b050', '#ffc000', '#c00000', '#1f497d'];
    */
  }

  public hideMe() {
    if (!this.zagolovok) {
      return {'visibility': 'hidden'};
    }
    return {};
  }
}

DynamicBootstrapper.register({ selector: homescreenPerformanceDiagramSelector, cls: HomescreenPerformanceDiagramComponent });
