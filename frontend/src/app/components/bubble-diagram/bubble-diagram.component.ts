import {Component, OnInit, ViewChild} from "@angular/core";
import {I18nService} from "core-app/modules/common/i18n/i18n.service";
import {ChartDataSets, ChartOptions, ChartPoint, ChartType} from "chart.js";
import {BaseChartDirective, Color, Label} from "ng2-charts";
import {TimezoneService} from "core-components/datetime/timezone.service";
import {HalResourceService} from "core-app/modules/hal/services/hal-resource.service";
import {PathHelperService} from "core-app/modules/common/path-helper/path-helper.service";
import {CollectionResource} from "core-app/modules/hal/resources/collection-resource";
import {ProjectResource} from "core-app/modules/hal/resources/project-resource";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";

export const bubbleDiagramSelector = 'bubble-diagram';

export interface ValueOption {
  name:string;
  id:string;
}

@Component({
  selector: bubbleDiagramSelector,
  templateUrl: './bubble-diagram.html'
})
export class BubbleDiagramComponent implements OnInit {
  public bubbleChartOptions:ChartOptions = {
    responsive: true,
    scales:{
      yAxes: [{
        ticks: {
          min: 0,
          max: 2,
          display: false
        },
        gridLines: {
          display: false,
          drawBorder: false,
        }
      }],
      xAxes: [{
        ticks: {
          min: 0,
          max: 4,
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
      labels: {
        boxWidth: 15
      }
    },
    // tooltips: {
    //   callbacks: {
    //     label: function (t, d) {
    //       if (d.labels) {
    //         return d.labels[t.index || 0];
    //       } else {
    //         return '';
    //       }
    //     }
    //   }
    // }
  };
  public bubbleChartColors:Color[] = [
    {
      backgroundColor: [
        'red',
        'green',
        'blue',
        'purple',
      ]
    }
  ];
  public bubbleChartLabels:Label[] = [];
  public bubbleChartType:ChartType = 'bubble';
  public bubbleChartLegend = true;
  public bubbleChartPlugins = [];
  public bubbleChartData:ChartDataSets[] = [{data: [], label: 'Объем инвестиций'}];
  public projectSelect:ValueOption | undefined;
  public projectSelectOptions:ValueOption[] = [];

  @ViewChild(BaseChartDirective) chart:BaseChartDirective;

  constructor(readonly timezoneService:TimezoneService,
              protected I18n:I18nService,
              protected halResourceService:HalResourceService,
              protected pathHelper:PathHelperService) { }

  ngOnInit() {
    this.getProjects().then((resources:CollectionResource<ProjectResource>) => {
      let els = resources.elements;
      this.projectSelectOptions = els.map(el => {
        return {name: el.name, id: el.getId()};
      });
      this.projectSelectOptions.unshift({name: 'Все проекты', id: '0'});
      this.projectSelect = this.projectSelectOptions[0];
    });
    this.halResourceService
      .get<HalResource>(this.pathHelper.api.v3.diagrams.toString() + '/bubble')
      .toPromise()
      .then((resource:HalResource) => {
        let labels:Label[] = [];
        resource.label.map((label:string) => {
          labels.push(label);
        });
        let smalldata:ChartPoint[] = [];
        let colors:string[] = [];
        resource.data.map((array:any) => {
          smalldata.push({x: array.x, y: array.y, r: array.r});
          colors.push("#" + ((array.id % 10) * 123456 + ((100000 - array.id) % 10) * 654321).toString(16).slice(-6));
        });
        this.bubbleChartLabels = labels;
        this.bubbleChartData[0].data = smalldata;
        this.bubbleChartColors[0].backgroundColor = colors;
      });
  }

  public filterChart() {
    this.halResourceService
      .get<HalResource>(this.pathHelper.api.v3.diagrams.toString() + '/bubble', {project: this.projectSelect ? this.projectSelect.id : 0 })
      .toPromise()
      .then((resource:HalResource) => {
        let labels:Label[] = [];
        resource.label.map((label:string) => {
          labels.push(label);
        });
        let smalldata:ChartPoint[] = [];
        let colors:string[] = [];
        resource.data.map((array:any) => {
          smalldata.push({x: array.x, y: array.y, r: array.r});
          colors.push("#" + ((array.id % 10) * 123456 + ((100000 - array.id) % 10) * 654321).toString(16).slice(-6));
        });
        this.bubbleChartLabels = labels;
        this.bubbleChartData[0].data = smalldata;
        this.bubbleChartColors[0].backgroundColor = colors;
      });
  }

  private getProjects():Promise<CollectionResource<ProjectResource>> {
    return this.halResourceService
      .get<CollectionResource<ProjectResource>>(this.pathHelper.api.v3.projects.toString())
      .toPromise();
  }
}
