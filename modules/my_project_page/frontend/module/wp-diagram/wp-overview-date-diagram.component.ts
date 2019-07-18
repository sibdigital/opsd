import {Component, ElementRef, OnInit, ViewChild} from "@angular/core";
import {ChartDataSets, ChartOptions, ChartType} from "chart.js";
import {BaseChartDirective, Label} from "ng2-charts";
import {I18nService} from "core-app/modules/common/i18n/i18n.service";
import {DynamicBootstrapper} from "core-app/globals/dynamic-bootstrapper";
import 'chartjs-plugin-labels';

export const dateDiagramSelector = 'wp-overview-date-diagram';

@Component({
  selector: dateDiagramSelector,
  templateUrl: './wp-overview-diagram-2.html'
})
export class WorkPackageOverviewDateDiagramComponent implements OnInit {
  public barChartOptions: ChartOptions = {
    responsive: true,
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

  public barChartLabels: Label[] = ['Фактически исполнено','Риски исполнения','Остаток финансовых средств'];
  public barChartType: ChartType = 'pie';
  public barChartLegend = true;
  public barChartPlugins = [];

  public barChartData: ChartDataSets[];
  public barChartData2: ChartDataSets[];

  @ViewChild(BaseChartDirective) chart: BaseChartDirective;

  constructor(protected I18n:I18nService,
              readonly element:ElementRef) { }

  ngOnInit() {
    this.barChartData = JSON.parse(this.element.nativeElement.getAttribute('chart-data'));
    this.barChartData[0].backgroundColor = ["#4f81bd", "#c0504d", "#9bbb59", "#8064a2"];
    this.barChartData2 = JSON.parse(this.element.nativeElement.getAttribute('chart-data-2'));
  }

  public changeChartType() {
    this.chart.chartType = this.barChartType;
    this.chart.chart.update();
  }
}

DynamicBootstrapper.register({ selector: dateDiagramSelector, cls: WorkPackageOverviewDateDiagramComponent });
