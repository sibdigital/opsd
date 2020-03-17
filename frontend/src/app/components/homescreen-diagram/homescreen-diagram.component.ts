import {Component, ElementRef, OnInit, ViewChild, Input} from '@angular/core';
import {ChartOptions, ChartType, ChartDataSets} from 'chart.js';
import {Label, BaseChartDirective} from 'ng2-charts';
import {I18nService} from "core-app/modules/common/i18n/i18n.service";
import {DynamicBootstrapper} from "core-app/globals/dynamic-bootstrapper";
import 'chartjs-plugin-labels';
import {HalResourceService} from "core-app/modules/hal/services/hal-resource.service";
import {PathHelperService} from "core-app/modules/common/path-helper/path-helper.service";
import {DiagramHomescreenResource} from "core-app/modules/hal/resources/diagram-homescreen-resource";

export const homescreenDiagramSelector = 'homescreen-diagram';

@Component({
  selector: homescreenDiagramSelector,
  templateUrl: './homescreen-diagram.html'
})
export class HomescreenDiagramComponent implements OnInit {
  @Input('data') public data:any[];
  @Input('chartLabels') public chartLabels:any[];
  @Input('chartColors') public chartColors:any[];
  @Input('chartOptions') public chartOptions:ChartOptions;
  @Input('chartPlugins') public chartPlugins:[];
  @Input('chartType') public chartType:any;
  @Input('chartLegend') public chartLegend:any;
  @Input('label') public label:any;

  public defaultChartOptions:ChartOptions = {
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
  public barChartOptions:ChartOptions;

  public barChartLabels:Label[];
  public barChartType:ChartType = 'pie';
  public barChartLegend = true;
  public barChartPlugins = [];
  public barChartData:ChartDataSets[] = [
    {
      data: [],
      label: '',
      backgroundColor: ['#00b050', '#ffc000', '#c00000', '#1f497d']
    }
  ];

  @ViewChild(BaseChartDirective) chart:BaseChartDirective;

  constructor(protected I18n:I18nService,
              readonly element:ElementRef,
              protected halResourceService:HalResourceService,
              protected pathHelper:PathHelperService) { }

  ngOnInit() {
    this.refresh();
/*    if (!this.raionId) {
      this.raionId = 0;
    }*/
/*    this.halResourceService
      .get<DiagramHomescreenResource>(this.pathHelper.api.v3.diagrams.toString() + '/' + barChartName/!*, {raionId: this.raionId}*!/)
      .toPromise()
      .then((resource:DiagramHomescreenResource) => {
        if (resource.label === 'visible') {
          this.element.nativeElement.parentElement.removeAttribute('style');
          this.element.nativeElement.parentElement.style.visibility = 'visible';
          this.element.nativeElement.parentElement.style.width = '350px';
        }
        if (resource.label === 'hidden') {
          this.element.nativeElement.parentElement.removeAttribute('style');
          this.element.nativeElement.parentElement.style.display = 'none';
        }
        this.barChartData[0].data = resource.data;
        this.barChartData[0].label = resource.label;
      });*/

  }

  ngOnChanges() {
    this.refresh();
  }

  protected refresh() {
    this.barChartType = this.chartType || this.barChartType; //default chart type
    this.barChartLabels = this.chartLabels || this.barChartLabels; //default chart labels
    this.barChartLegend = this.chartLegend ||  true;
    this.barChartPlugins = this.chartPlugins || [];
    this.barChartOptions = this.chartOptions || this.defaultChartOptions;
    this.barChartData = [
      {
        data: this.data || [], //default data set
        label: this.label || '', //default label
        backgroundColor: this.chartColors || ['#00b050', '#ffc000', '#c00000', '#1f497d'] //default color set
      }
    ];
    /*let barChartName = this.element.nativeElement.getAttribute('chart-name') || 0;
    this.halResourceService
      .get<DiagramHomescreenResource>(this.pathHelper.api.v3.diagrams.toString() + '/' + barChartName, {project: project})
      .toPromise()
      .then((resource:DiagramHomescreenResource) => {
        this.barChartData[0].data = resource.data;
        this.barChartData[0].label = resource.label;
        if (resource.label === 'visible') {
          this.element.nativeElement.parentElement.removeAttribute('style');
          this.element.nativeElement.parentElement.style.visibility = 'visible';
          this.element.nativeElement.parentElement.style.width = '350px';
        }
        if (resource.label === 'hidden') {
          this.element.nativeElement.parentElement.removeAttribute('style');
          this.element.nativeElement.parentElement.style.display = 'none';
        }
      });*/
  }

  public refreshByMunicipality(raionId:number) {
/*    let barChartName = this.element.nativeElement.getAttribute('chart-name') || 0;
    this.halResourceService
      .get<DiagramHomescreenResource>(this.pathHelper.api.v3.diagrams.toString() + '/' + barChartName, {raionId: raionId})
      .toPromise()
      .then((resource:DiagramHomescreenResource) => {
        this.barChartData[0].data = resource.data;
        this.barChartData[0].label = resource.label;
        if (resource.label === 'visible') {
          this.element.nativeElement.parentElement.removeAttribute('style');
          this.element.nativeElement.parentElement.style.visibility = 'visible';
          this.element.nativeElement.parentElement.style.width = '350px';
        }
        if (resource.label === 'hidden') {
          this.element.nativeElement.parentElement.removeAttribute('style');
          this.element.nativeElement.parentElement.style.display = 'none';
        }
      });*/
  }
}

DynamicBootstrapper.register({ selector: homescreenDiagramSelector, cls: HomescreenDiagramComponent });
