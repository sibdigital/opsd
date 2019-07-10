import {Component, ElementRef, Input, OnInit,ViewChild} from "@angular/core";
import {ChartOptions, ChartType, ChartDataSets} from "chart.js";
import {Label, BaseChartDirective} from "ng2-charts";
import {I18nService} from "core-app/modules/common/i18n/i18n.service";
import {DynamicBootstrapper} from "core-app/globals/dynamic-bootstrapper";


export const statusDiagramSelector = 'wp-overview-diagram';

@Component(
{
  selector: statusDiagramSelector,
  templateUrl: './wp-overview-diagram.html'
})


export class WorkPackageOverviewStatusDiagramComponent implements OnInit {
  public barChartOptions: ChartOptions = {
    responsive: true,
    scales: {
      yAxes: [{
        ticks: {
          beginAtZero: true
        }
      }]
    }
  };

  public barChartLabels: Label[] = [this.I18n.t('js.work_packages.properties.status')];
  public barChartType: ChartType = 'bar';
  public barChartLegend = true;
  public barChartPlugins = [];

  public barChartData: ChartDataSets[];

  @ViewChild(BaseChartDirective) chart: BaseChartDirective;

  constructor(protected I18n:I18nService,
              readonly element:ElementRef) { }

  ngOnInit() {
    this.barChartData = JSON.parse(this.element.nativeElement.getAttribute('chart-data'));
  }

  public changeChartType() {
    this.chart.chartType = this.barChartType;
    this.chart.chart.update();
  }
}
DynamicBootstrapper.register({ selector: statusDiagramSelector, cls: WorkPackageOverviewStatusDiagramComponent });
