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
  private value:{ [attribute:string]:any } | undefined = {};
  public valueOptions:ValueOption[] = [];
  protected readonly appBasePath:string;

  @ViewChild(HomescreenBlueTableComponent) blueChild:HomescreenBlueTableComponent;

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
          return {name: el.name, identifier: el.identifier};
        });
        this.valueOptions.push({ identifier: "default_general_route", name: "Совещания по общим вопросам"});
        this.value = this.valueOptions[0];
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
}
