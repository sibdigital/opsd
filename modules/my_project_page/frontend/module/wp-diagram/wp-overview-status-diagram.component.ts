import {Component, ElementRef, Input, OnInit} from '@angular/core';
import {ChartOptions, ChartType, ChartDataSets} from 'chart.js';
import {Label} from 'ng2-charts';
import {I18nService} from "core-app/modules/common/i18n/i18n.service";

@Component({
  selector: 'wp-overview-status-diagram',
  templateUrl: './wp-overview-diagram.html'
})
export class WorkPackageOverviewStatusDiagramComponent implements OnInit {
  public barChartOptions: ChartOptions = {
    responsive: true,
  };
  public barChartLabels: Label[] = [this.I18n.t('js.work_packages.properties.status')];
  public barChartType: ChartType = 'bar';
  public barChartLegend = true;
  public barChartPlugins = [];

  public barChartData: ChartDataSets[];

  constructor(protected I18n:I18nService,
              readonly element:ElementRef) { }

  ngOnInit() {
    this.barChartData = JSON.parse(this.element.nativeElement.getAttribute('chart-data'));
  }
}
