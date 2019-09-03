import {Component, ViewChild} from "@angular/core";
import {HomescreenBlueTableComponent} from "core-components/homescreen-blue-table/homescreen-blue-table.component";
import {AngularTrackingHelpers} from "core-components/angular/tracking-functions";
import {HalResourceService} from "core-app/modules/hal/services/hal-resource.service";
import {PathHelperService} from "core-app/modules/common/path-helper/path-helper.service";
import {CollectionResource} from "core-app/modules/hal/resources/collection-resource";
import {HalResource} from "core-app/modules/hal/resources/hal-resource";
import {StateService} from "@uirouter/core";

interface ValueOption {
  name:string;
  kurator:string;
  rukovoditel:string;
  $href:number | null;
}

@Component({
  templateUrl: './problems-tab.html'
})
export class ProblemsTabComponent {
  public curator:string = '';
  public ruk:string = '';
  private value:{ [attribute:string]:any } | undefined = {};
  public valueOptions:ValueOption[] = [];
  public compareByHref = AngularTrackingHelpers.compareByHref;

  @ViewChild(HomescreenBlueTableComponent) blueChild:HomescreenBlueTableComponent;

  constructor(protected halResourceService:HalResourceService,
              protected pathHelper:PathHelperService,
              readonly $state:StateService) {
  }

  ngOnInit() {
    this.halResourceService.get<CollectionResource<HalResource>>(this.pathHelper.api.v3.projects.toString())
      .toPromise()
      .then((projects:CollectionResource<HalResource>) => {
        this.valueOptions = projects.elements.map((el:HalResource) => {
          return {name: el.name, kurator: el.curator ? el.curator.fio : '', rukovoditel: el.rukovoditel ? el.rukovoditel.fio : '' , $href: el.id};
        });
        this.valueOptions.unshift({name: 'Все проекты', kurator: '-', rukovoditel:'-', $href: 0});
        this.value = this.valueOptions[0];
        if (this.$state.params.id) {
          let option:ValueOption | undefined = _.find(this.valueOptions, o => String(o.$href) === this.$state.params.id);
          if (option !== undefined) {
            this.selectedOption = option;
          }
        }
      });
  }

  public get selectedOption() {
    const href = this.value ? this.value.$href : null;
    return _.find(this.valueOptions, o => o.$href === href)!;
  }

  public set selectedOption(val:ValueOption) {
    let option = _.find(this.valueOptions, o => o.$href === val.$href);
    this.value = option;
  }

  public handleUserSubmit() {
    if (this.selectedOption) {
      this.blueChild.changeFilter('project' + this.selectedOption.$href);
      this.curator = this.selectedOption.kurator;
      this.ruk = this.selectedOption.rukovoditel;
    }
  }
}
