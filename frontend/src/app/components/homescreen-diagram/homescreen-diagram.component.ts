import {Component, ElementRef, OnInit, ViewChild} from '@angular/core';
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
  public barChartOptions:ChartOptions = {
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

  public barChartLabels:Label[];
  public barChartType:ChartType;
  public barChartLegend = true;
  public barChartPlugins = [];
  public barChartData:ChartDataSets[] = [
    {data:[]}
  ];

  @ViewChild(BaseChartDirective) chart:BaseChartDirective;

  constructor(protected I18n:I18nService,
              readonly element:ElementRef,
              protected halResourceService:HalResourceService,
              protected pathHelper:PathHelperService) { }

  ngOnInit() {
    this.barChartType = this.element.nativeElement.getAttribute('chart-type') || 'pie'; //default diagram
    this.barChartLabels = JSON.parse(this.element.nativeElement.getAttribute('chart-labels'));
    let barChartName = this.element.nativeElement.getAttribute('chart-name') || 0;
    //let organization = this.element.nativeElement.getAttribute('organization-id') || 0;
    this.halResourceService
      .get<DiagramHomescreenResource>(this.pathHelper.api.v3.diagrams.toString() + '/' + barChartName, /*{organization: organization}*/)
      .toPromise()
      .then((resource:DiagramHomescreenResource) => {
        this.barChartData[0].data = resource.data;
        this.barChartData[0].label = resource.label;
        if (resource.label === 'visible') {
          //this.element.nativeElement.parentElement.removeAttribute('style');
          this.element.nativeElement.parentElement.style.visibility = 'visible';
          this.element.nativeElement.parentElement.style.width = '350px';
        }
        if (resource.label === 'hidden') {
          this.element.nativeElement.parentElement.removeAttribute('style');
          this.element.nativeElement.parentElement.style.display = 'none';
        }
      });
    this.barChartData[0].backgroundColor = JSON.parse(this.element.nativeElement.getAttribute('chart-colors')) || ['#00b050', '#ffc000', '#c00000', '#1f497d']; //default color set
  }

  /*public refresh() {
    let barChartName = this.element.nativeElement.getAttribute('chart-name') || 0;
    let organization = this.element.nativeElement.getAttribute('organization-id') || 0;
    this.halResourceService
      .get<DiagramHomescreenResource>(this.pathHelper.api.v3.diagrams.toString() + '/' + barChartName, {organization: organization})
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
      });
  }*/
}

DynamicBootstrapper.register({ selector: homescreenDiagramSelector, cls: HomescreenDiagramComponent });
