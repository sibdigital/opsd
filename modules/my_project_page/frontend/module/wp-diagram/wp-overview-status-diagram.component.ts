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
      position: 'top',
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

  public barChartLabels: Label[] = ['Решено','Предстоящие в 2 недели','Не исполнено','Проблем'];
  public barChartType: ChartType = 'pie';
  public barChartLegend = true;
  public barChartPlugins = [];

  public barChartData: ChartDataSets[];

  @ViewChild(BaseChartDirective) chart: BaseChartDirective;

  constructor(protected I18n:I18nService,
              readonly element:ElementRef) { }

  ngOnInit() {
    this.barChartData = JSON.parse(this.element.nativeElement.getAttribute('chart-data'));
    this.barChartType = this.element.nativeElement.getAttribute('chart-type');
    if(this.barChartType===null)
    {
      this.barChartType='pie';
    }

    this.barChartData[0].backgroundColor = ["#00b050", "#ffc000", "#c00000", "#1f497d"];
    if(this.barChartData[0].label === 'false' && this.barChartOptions.legend){
      this.barChartOptions.legend.display = false;
    }
  }

  public changeChartType() {
    this.chart.chartType = this.barChartType;
    this.chart.chart.update();
  }
}
DynamicBootstrapper.register({ selector: statusDiagramSelector, cls: WorkPackageOverviewStatusDiagramComponent });
