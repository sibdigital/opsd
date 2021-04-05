import {Component, OnInit, ViewChild} from "@angular/core";
import {HomescreenBlueTableComponent} from "core-components/homescreen-blue-table/homescreen-blue-table.component";
import {CollectionResource} from "core-app/modules/hal/resources/collection-resource";
import {HalResourceService} from "core-app/modules/hal/services/hal-resource.service";
import {PathHelperService} from "core-app/modules/common/path-helper/path-helper.service";
import {I18nService} from "core-app/modules/common/i18n/i18n.service";
import {ProjectResource} from "core-app/modules/hal/resources/project-resource";
import {AngularTrackingHelpers} from "core-components/angular/tracking-functions";

export interface ValueOption {
  name:string;
  identifier:string | null;
}

@Component({
  templateUrl: './protocol-tab.html'
})
export class ProtocolTabComponent implements OnInit {
  public compareByHref = AngularTrackingHelpers.compareByHref;
  public options:any[];
  keyword = 'name';
  data_autocomplete:any[] = [];
  data_choosed:any;
  is_loading:boolean[] = [true];
  private value:{ [attribute:string]:any } | undefined = {};
  public valueOptions:ValueOption[] = [];
  protected readonly appBasePath:string;

  @ViewChild(HomescreenBlueTableComponent) blueChild:HomescreenBlueTableComponent;
  @ViewChild('autocomplete') auto:any;

  constructor(protected halResourceService:HalResourceService,
              protected pathHelper:PathHelperService,
              readonly I18n:I18nService) {
    this.appBasePath = window.appBasePath ? window.appBasePath : '';
  }

  ngOnInit() {
    this.halResourceService.get<CollectionResource<ProjectResource>>(this.pathHelper.api.v3.projects_for_user.toString())
      .toPromise()
      .then((projects:CollectionResource<ProjectResource>) => {
        this.valueOptions = projects.elements.map((el:ProjectResource) => {
          this.data_autocomplete.push({id: el.id, name: el.name});
          return {name: el.name, identifier: el.identifier};
        });
        this.valueOptions.push({ identifier: "default_general_route", name: "Совещания по общим вопросам"});
        this.data_autocomplete.push({ id: "default_general_route", name: "Совещания по общим вопросам"});
        this.value = this.valueOptions[0];
        this.is_loading[0] = false;
      });
  }

  public get selectedOption() {
    const identifier = this.value ? this.value.identifier : null;
    return _.find(this.valueOptions, o => o.identifier === identifier)!;
  }

  public set selectedOption(val:ValueOption) {
    let option = _.find(this.valueOptions, o => o.identifier === val.identifier);
    this.value = option;
  }
  public check(item:any) {
    // console.log(this.auto);
    // console.log(item);
    // console.log(item.selected);
  }
  public check_load() {
    // console.log(this.is_loading);
    return this.is_loading[0];

    // let is_ready = true;
    // this.is_loading.forEach(value => (is_ready = value || is_ready));
    // return is_ready;
  }

  public handleUserSubmit() {
    if (this.selectedOption) {
      if (this.selectedOption.identifier === "default_general_route") {
        window.open(this.appBasePath + "/general_meetings");
      }
      else {
        window.open(this.appBasePath + "/projects/" + this.selectedOption.identifier + "/meetings/new", "_blank");
      }
    }
  }

  selectEvent(item:any) {
    this.auto.close();
    this.data_choosed = item;
    if (this.data_choosed.id === "default_general_route") {
      window.open(this.appBasePath + "/general_meetings");
    }
    else {
      window.open(this.appBasePath + "/projects/" + this.data_choosed.id + "/meetings/new", "_blank");
    }
  }

  clearEvent() {
    this.auto.close();
  }
}
