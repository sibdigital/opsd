import {Component, Input, OnInit} from '@angular/core';
import {ChartOptions, ChartType, ChartDataSets} from 'chart.js';
import {Label} from 'ng2-charts';
import {I18nService} from "core-app/modules/common/i18n/i18n.service";
import {DynamicBootstrapper} from "core-app/globals/dynamic-bootstrapper";
import {appBaseSelector, ApplicationBaseComponent} from "core-app/modules/router/base/application-base.component";

export const homescreenDiagramSelector = 'wp-homescreen-done-ratio-diagram';

@Component({
  selector: homescreenDiagramSelector,
  templateUrl: './wp-homescreen-done-ratio-diagram.html'
})
export class WorkPackageHomescreenDoneRatioDiagramComponent implements OnInit {
  public barChartOptions:ChartOptions = {
    responsive: true,
  };
  public barChartLabels:Label[] = [this.I18n.t('js.activities')];
  public barChartType:ChartType = 'bar';
  public barChartLegend = true;
  public barChartPlugins = [];
  public barChartData:ChartDataSets[] = [{data: [65], label: '5-Series'}];

  constructor(protected I18n:I18nService) { }

  ngOnInit() {
    console.log("1");
  }
}

DynamicBootstrapper.register({ selector: homescreenDiagramSelector, cls: WorkPackageHomescreenDoneRatioDiagramComponent });
