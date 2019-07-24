import {Component, ElementRef, OnInit} from '@angular/core';
import {ChartOptions, ChartType, ChartDataSets} from 'chart.js';
import {Label} from 'ng2-charts';
import {I18nService} from "core-app/modules/common/i18n/i18n.service";


@Component({
  selector: 'wp-overview-diagram-tab',
  templateUrl: './overview-diagram-tab.html'
})
export class WorkPackageOverviewDiagramTabComponent implements OnInit {
  public barChartOptions:ChartOptions = {
    responsive: true,
    scales: {
      yAxes: [{
        ticks: {
          beginAtZero: true
        }
      }]
    }
  };
  public barChartLabels:Label[] = [this.I18n.t('js.activities')];
  public barChartType:ChartType = 'bar';
  public barChartLegend = true;
  public barChartPlugins = [];

  public barChartData:ChartDataSets[];

  constructor(protected I18n:I18nService,
              readonly element:ElementRef) { }

  ngOnInit() {
    this.barChartData = [
      { data: [65, 59, 80, 81, 56, 55, 40], label: 'Series A' },
      { data: [28, 48, 40, 19, 86, 27, 90], label: 'Series B' }
    ];
  }
}
