import {Component, ElementRef, OnInit, ViewChild} from "@angular/core";
import {ChartDataSets, ChartOptions, ChartType} from "chart.js";
import {BaseChartDirective, Label} from "ng2-charts";
import {I18nService} from "core-app/modules/common/i18n/i18n.service";
import {DynamicBootstrapper} from "core-app/globals/dynamic-bootstrapper";

export const dateDiagramSelector = 'wp-overview-date-diagram';

@Component({
  selector: dateDiagramSelector,
  templateUrl: './wp-overview-diagram.html'
})
export class WorkPackageOverviewDateDiagramComponent implements OnInit {
  public barChartOptions: ChartOptions = {
    responsive: true,
  };
  public barChartLabels: Label[] = [this.I18n.t('js.activities')];
  public barChartType: ChartType = 'bar';
  public barChartLegend = true;
  public barChartPlugins = [];

  public barChartData: ChartDataSets[];
  public barChartBubbleData: ChartDataSets[]=new Array(5);

  constructor(protected I18n:I18nService,
              readonly element:ElementRef) { }

  @ViewChild(BaseChartDirective) chart: BaseChartDirective;

  ngOnInit() {
    this.barChartData = JSON.parse(this.element.nativeElement.getAttribute('chart-data'));
    //   for (let i=0;i<this.barChartData.length;i++)
    //   {
    //     let newDataset ={
    //       label: this.barChartData[i].label,
    //       hidden: this.barChartData[i].data[0]===0,
    //       data: [{
    //         x: parseInt(this.barChartData[i].data[0].toString()),
    //         y: parseInt(this.barChartData[i].data[0].toString()),
    //         r: 10
    //       }]
    //     };
    //
    //     this.barChartBubbleData[i]= newDataset;
    //   }
    //   this.barChartData=this.barChartBubbleData;
    // }
  }

  public changeChartType(){
    this.chart.chartType = this.barChartType;
    this.chart.chart.update();
  }
}

DynamicBootstrapper.register({ selector: dateDiagramSelector, cls: WorkPackageOverviewDateDiagramComponent });
