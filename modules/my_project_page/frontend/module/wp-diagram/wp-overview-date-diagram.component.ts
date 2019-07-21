import {Component, ElementRef, OnInit, ViewChild} from "@angular/core";
import {ChartDataSets, ChartOptions, ChartType} from "chart.js";
import {BaseChartDirective, Label} from "ng2-charts";
import {I18nService} from "core-app/modules/common/i18n/i18n.service";
import {DynamicBootstrapper} from "core-app/globals/dynamic-bootstrapper";
//import 'chartjs-plugin-labels';

export const dateDiagramSelector = 'wp-overview-date-diagram';

@Component({
  selector: dateDiagramSelector,
  templateUrl: './wp-overview-diagram-2.html'
})
export class WorkPackageOverviewDateDiagramComponent implements OnInit {
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

  public barChartLabels: Label[];
  public barChartType: ChartType = 'pie';
  public barChartLegend = true;
  public barChartPlugins = [];

  public barChartData: ChartDataSets[] = [{label:'undefined',backgroundColor: ['#00b050', '#ffc000', '#c00000', '#1f497d']}];

  @ViewChild(BaseChartDirective) chart: BaseChartDirective;

  constructor(protected I18n:I18nService,
              readonly element:ElementRef) { }

  ngOnInit() {
    this.barChartLabels = JSON.parse(this.element.nativeElement.getAttribute('chart-labels'));
    let arr = [];
    for(let i=0;i<this.barChartLabels.length;i++){
      arr.push(0);
    }
//  if(this.barChartData[0].data){
    this.barChartData[0].data = arr;
//}
    this.barChartData[0].backgroundColor = ["#00b050", "#ffc000", "#c00000", "#1f497d"];
  }

  public changeChartType() {
    this.chart.chartType = this.barChartType;
    this.chart.chart.update();
  }
}

DynamicBootstrapper.register({ selector: dateDiagramSelector, cls: WorkPackageOverviewDateDiagramComponent });
