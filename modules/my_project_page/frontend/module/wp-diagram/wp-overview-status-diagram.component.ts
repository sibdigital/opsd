import {Component, ElementRef, Input, OnInit,ViewChild} from "@angular/core";
import {ChartOptions, ChartType, ChartDataSets} from "chart.js";
import {Label, BaseChartDirective} from "ng2-charts";
import {I18nService} from "core-app/modules/common/i18n/i18n.service";
import {DynamicBootstrapper} from "core-app/globals/dynamic-bootstrapper";
import 'chartjs-plugin-labels';

export const statusDiagramSelector = 'wp-overview-status-diagram';

@Component(
{
  selector: statusDiagramSelector,
  templateUrl: './wp-overview-diagram.html'
})


export class WorkPackageOverviewStatusDiagramComponent implements OnInit {
  public barChartOptions: ChartOptions = {
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
          display: false
        },
        gridLines: {
          display: false,
          drawBorder: false,
        }
      }]
    },
    legend: {
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

  public barChartLabels: Label[] = [];
  public barChartType: ChartType = 'pie';
  public barChartLegend = true;
  public barChartPlugins = [];

  public barChartData: ChartDataSets[];

  @ViewChild(BaseChartDirective) chart: BaseChartDirective;

  constructor(protected I18n:I18nService,
              readonly element:ElementRef) { }

  ngOnInit() {
    this.barChartLabels = JSON.parse(this.element.nativeElement.getAttribute('chart-labels'));
    this.barChartData = JSON.parse(this.element.nativeElement.getAttribute('chart-data'));
    this.barChartData[0].backgroundColor = JSON.parse(this.element.nativeElement.getAttribute('chart-colors'));
    if(this.barChartData[0].label === 'false' && this.barChartOptions.legend){
      this.barChartOptions.legend.display = false;
      //this.barChartOptions.legend.labels.boxWidth
    }
  }

  public changeChartType() {
    this.chart.chartType = this.barChartType;
    this.chart.chart.update();
  }
}
DynamicBootstrapper.register({ selector: statusDiagramSelector, cls: WorkPackageOverviewStatusDiagramComponent });
